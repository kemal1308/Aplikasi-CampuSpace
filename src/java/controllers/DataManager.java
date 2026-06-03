package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.Fasilitas;
import models.Ruangan;
import models.AlatElektronik;
import models.Peminjaman;
import org.mindrot.jbcrypt.BCrypt;

public class DataManager {

    // =========================================================
    //   SISTEM AUTO-IMAGE (GAMBAR ANTI-BROKEN)
    // =========================================================
    private String getAutoGambarUrl(String urlDariDB, String tipe, String namaFasilitas) {
        if (urlDariDB != null && !urlDariDB.trim().isEmpty()) {
            return urlDariDB; 
        }
        
        String nama = namaFasilitas.toLowerCase();
        
        if ("RUANGAN".equals(tipe)) {
            if (nama.contains("auditorium") || nama.contains("aula") || nama.contains("damar") || nama.contains("teater")) {
                return "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80"; 
            } else if (nama.contains("lapangan") || nama.contains("sport") || nama.contains("futsal") || nama.contains("basket")) {
                return "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800&q=80";
            } else if (nama.contains("lab") || nama.contains("laboratorium") || nama.contains("komputer")) {
                return "https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800&q=80";
            } else {
                return "https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&q=80"; 
            }
            
        } else {
            if (nama.contains("proyektor") || nama.contains("projector")) {
                return "https://images.unsplash.com/photo-1574717024453-354056aafd6c?w=800&q=80";
            } else if (nama.contains("mic") || nama.contains("suara") || nama.contains("speaker") || nama.contains("shure")) {
                return "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=800&q=80";
            } else if (nama.contains("kamera") || nama.contains("camera") || nama.contains("dslr")) {
                return "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80";
            } else {
                return "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&q=80"; 
            }
        }
    }

    // --- 1. MENGAMBIL SEMUA FASILITAS (KATALOG) ---
    public List<Fasilitas> getAllFasilitas() {
        List<Fasilitas> daftarFasilitas = new ArrayList<>();
        String query = "SELECT * FROM fasilitas";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                String id = rs.getString("id_fasilitas");
                String nama = rs.getString("nama_fasilitas");
                boolean isTersedia = rs.getBoolean("is_tersedia");
                String tipe = rs.getString("tipe_fasilitas");
                
                String gambar = getAutoGambarUrl(rs.getString("gambar_url"), tipe, nama);

                if ("RUANGAN".equals(tipe)) {
                    int kapasitas = rs.getInt("kapasitas_gedung");
                    boolean berAC = rs.getBoolean("ber_ac");
                    String lokasi = rs.getString("lokasi_gedung");
                    Ruangan r = new Ruangan(id, nama, isTersedia, kapasitas, berAC, lokasi);
                    r.setGambarUrl(gambar);
                    daftarFasilitas.add(r);
                } else if ("ALAT_ELEKTRONIK".equals(tipe)) {
                    String jenis = rs.getString("jenis_alat");
                    String merk = rs.getString("merk_alat");
                    String kondisi = rs.getString("kondisi");
                    AlatElektronik a = new AlatElektronik(id, nama, isTersedia, jenis, merk, kondisi);
                    a.setGambarUrl(gambar);
                    daftarFasilitas.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return daftarFasilitas;
    }

    // --- 2. MENYIMPAN DATA RESERVASI TRANSAKSI ---
    public boolean simpanReservasi(String idPeminjaman, String idFasilitas, String idPengguna, java.sql.Date tglPinjam, java.sql.Date tglKembali, String keperluan) {
        
        // Tambahkan kolom 'keperluan' di dalam query INSERT
        String queryInsertPeminjaman = "INSERT INTO peminjaman (id_peminjaman, id_fasilitas, id_pengguna, tanggal_pinjam, tanggal_kembali, status_peminjaman, total_denda, status_denda, keperluan) VALUES (?, ?, ?, ?, ?, 'PENDING', 0, 'BELUM_DIBAYAR', ?)";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement stmtInsert = conn.prepareStatement(queryInsertPeminjaman)) {
             
            stmtInsert.setString(1, idPeminjaman);
            stmtInsert.setString(2, idFasilitas);
            stmtInsert.setString(3, idPengguna);
            stmtInsert.setDate(4, tglPinjam);
            stmtInsert.setDate(5, tglKembali);
            
            // Masukkan data keperluan ke tanda tanya (?) ke-6
            stmtInsert.setString(6, keperluan);
            
            return stmtInsert.executeUpdate() > 0;
        } catch (java.sql.SQLException e) {
            System.out.println("GAGAL SIMPAN RESERVASI: " + e.getMessage());
            e.printStackTrace(); 
            return false;
        }
    }
public String cekKetersediaanJadwal(String idFasilitas, java.sql.Date tglPinjamBaru, java.sql.Date tglKembaliBaru) {
        // Logika: Cek apakah tglPinjam <= tglKembali_Ada DAN tglKembali >= (tglPinjam_Ada - 1 Hari)
        String query = "SELECT tanggal_pinjam, tanggal_kembali FROM peminjaman " +
                       "WHERE id_fasilitas = ? AND status_peminjaman IN ('PENDING', 'APPROVED', 'DIPINJAM') " +
                       "AND (? <= tanggal_kembali) AND (? >= (tanggal_pinjam - INTERVAL '1 day')::date)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idFasilitas);
            stmt.setDate(2, tglPinjamBaru);
            stmt.setDate(3, tglKembaliBaru);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate("tanggal_pinjam").toString() + " s/d " + rs.getDate("tanggal_kembali").toString();
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null; // Null berarti aman, tidak ada bentrok
    }

    // --- AMBIL JADWAL TERBOOKING UNTUK KATALOG ---
    public List<String> getJadwalTerbooking(String idFasilitas) {
        List<String> listJadwal = new ArrayList<>();
        String query = "SELECT tanggal_pinjam, tanggal_kembali FROM peminjaman WHERE id_fasilitas = ? AND status_peminjaman IN ('PENDING', 'APPROVED', 'DIPINJAM') AND tanggal_kembali >= CURRENT_DATE ORDER BY tanggal_pinjam ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idFasilitas);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    listJadwal.add("• " + rs.getDate("tanggal_pinjam").toString() + " s/d " + rs.getDate("tanggal_kembali").toString());
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return listJadwal;
    }
    
    // --- OPTIMASI BATCH: AMBIL SEMUA JADWAL AKTIF SEKALIGUS (MENCEGAH N+1 QUERY & LEMOT) ---
    public java.util.Map<String, java.util.List<String>> getAllJadwalAktif() {
        java.util.Map<String, java.util.List<String>> mapJadwal = new java.util.HashMap<>();
        String query = "SELECT id_fasilitas, tanggal_pinjam, tanggal_kembali FROM peminjaman WHERE status_peminjaman IN ('PENDING', 'APPROVED', 'DIPINJAM') AND tanggal_kembali >= CURRENT_DATE ORDER BY tanggal_pinjam ASC";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(query);
             java.sql.ResultSet rs = stmt.executeQuery()) {
             
            while (rs.next()) {
                String idFasilitas = rs.getString("id_fasilitas");
                String infoJadwal = "• " + rs.getDate("tanggal_pinjam").toString() + " s/d " + rs.getDate("tanggal_kembali").toString();
                
                // Masukkan jadwal ke keranjang fasilitas yang sesuai
                mapJadwal.putIfAbsent(idFasilitas, new java.util.ArrayList<>());
                mapJadwal.get(idFasilitas).add(infoJadwal);
            }
        } catch (java.sql.SQLException e) { 
            e.printStackTrace(); 
        }
        return mapJadwal;
    }

    // --- 3. MENGAMBIL RIWAYAT PEMINJAMAN SPESIFIK USER ---
    public List<Peminjaman> getPeminjamanByPengguna(String idPengguna) {
        List<Peminjaman> daftarPinjam = new ArrayList<>();
        String query = "SELECT * FROM peminjaman WHERE id_pengguna = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, idPengguna);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Peminjaman p = new Peminjaman();
                    p.setIdPeminjaman(rs.getString("id_peminjaman"));
                    p.setIdFasilitas(rs.getString("id_fasilitas"));
                    p.setIdPengguna(rs.getString("id_pengguna"));
                    p.setTanggalPinjam(rs.getDate("tanggal_pinjam"));
                    p.setTanggalKembali(rs.getDate("tanggal_kembali"));
                    p.setStatusPeminjaman(rs.getString("status_peminjaman"));
                    p.setStatusDenda(rs.getString("status_denda"));
                    p.setBuktiPembayaran(rs.getString("bukti_pembayaran"));
                    daftarPinjam.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return daftarPinjam;
    }

    // --- 4. OPSI LOGIN SSO OTOMATIS (USER) ---
    public String[] prosesLoginSSO(String emailInput, String roleInput) {
        String tipePengguna = roleInput.toUpperCase();
        String queryCheck = "SELECT * FROM pengguna WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmtCheck = conn.prepareStatement(queryCheck)) {

            stmtCheck.setString(1, emailInput);
            try (ResultSet rs = stmtCheck.executeQuery()) {
                if (rs.next()) {
                    return new String[] {rs.getString("id_pengguna"), rs.getString("nama_pengguna"), rs.getString("tipe_pengguna")};
                } else {
                    String username = emailInput.split("@")[0];
                    String idPenggunaBaru = (tipePengguna.equals("DOSEN") ? "DSN-" : "MHS-") + System.currentTimeMillis();
                    String queryInsert = "INSERT INTO pengguna (id_pengguna, nama_pengguna, tipe_pengguna, max_pinjam, max_item, email) VALUES (?, ?, ?, ?, ?, ?)";
                    
                    try (PreparedStatement stmtInsert = conn.prepareStatement(queryInsert)) {
                        int maxPinjam = tipePengguna.equals("DOSEN") ? 7 : 3;
                        int maxItem = tipePengguna.equals("DOSEN") ? 5 : 2;

                        stmtInsert.setString(1, idPenggunaBaru);
                        stmtInsert.setString(2, username);
                        stmtInsert.setString(3, tipePengguna);
                        stmtInsert.setInt(4, maxPinjam);
                        stmtInsert.setInt(5, maxItem);
                        stmtInsert.setString(6, emailInput);
                        stmtInsert.executeUpdate();
                        
                        return new String[] {idPenggunaBaru, username, tipePengguna};
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // --- 5. UPDATE PROFIL (MELENGKAPI NIM) ---
    public boolean updateNimPengguna(String idPengguna, String nimBaru) {
        String query = "UPDATE pengguna SET nim = ? WHERE id_pengguna = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, nimBaru);
            stmt.setString(2, idPengguna);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // --- 6. MENDAPATKAN NAMA FASILITAS BERDASARKAN ID ---
    public String getNamaFasilitas(String idFasilitas) {
        String nama = "Fasilitas Tidak Diketahui";
        String query = "SELECT nama_fasilitas FROM fasilitas WHERE id_fasilitas = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idFasilitas);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    nama = rs.getString("nama_fasilitas");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return nama;
    }

    // --- 7. MENGAMBIL BATAS MAKSIMAL PINJAM BERDASARKAN ROLE USER ---
    public int getMaxPinjam(String idPengguna) {
        int maxHari = 3; 
        String query = "SELECT max_pinjam FROM pengguna WHERE id_pengguna = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idPengguna);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    maxHari = rs.getInt("max_pinjam");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return maxHari;
    }
    
    // =========================================================
    //       FUNGSI KHUSUS ADMIN & DENDA
    // =========================================================

    public List<Peminjaman> getPendingReservasi() {
        List<Peminjaman> list = new ArrayList<>();
        String query = "SELECT * FROM peminjaman WHERE status_peminjaman = 'PENDING' OR status_peminjaman IS NULL";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Peminjaman p = new Peminjaman();
                p.setIdPeminjaman(rs.getString("id_peminjaman"));
                p.setIdFasilitas(rs.getString("id_fasilitas"));
                p.setIdPengguna(rs.getString("id_pengguna"));
                p.setTanggalPinjam(rs.getDate("tanggal_pinjam"));
                try {
                    String teksKeperluan = rs.getString("keperluan");
                    p.setKeperluan(teksKeperluan != null ? teksKeperluan : "-");
                } catch (Exception e) {
                    p.setKeperluan("-");
                }                
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Peminjaman> getRiwayatReservasi() {
        List<Peminjaman> list = new ArrayList<>();
        String query = "SELECT * FROM peminjaman WHERE status_peminjaman != 'PENDING' ORDER BY tanggal_pinjam DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Peminjaman p = new Peminjaman();
                p.setIdPeminjaman(rs.getString("id_peminjaman"));
                p.setIdFasilitas(rs.getString("id_fasilitas"));
                p.setIdPengguna(rs.getString("id_pengguna"));
                p.setTanggalPinjam(rs.getDate("tanggal_pinjam"));
                p.setStatusPeminjaman(rs.getString("status_peminjaman"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatusPeminjaman(String idPeminjaman, String statusBaru) {
        String query = "UPDATE peminjaman SET status_peminjaman = ? WHERE id_peminjaman = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, statusBaru);
            stmt.setString(2, idPeminjaman);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean uploadBuktiTransfer(String idPeminjaman, String namaFile) {
        String query = "UPDATE peminjaman SET bukti_pembayaran = ?, status_denda = 'MENUNGGU_VERIFIKASI' WHERE id_peminjaman = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, namaFile);
            stmt.setString(2, idPeminjaman);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean verifikasiDendaSelesai(String idPeminjaman) {
        String query = "UPDATE peminjaman SET status_denda = 'LUNAS', status_peminjaman = 'SELESAI' WHERE id_peminjaman = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idPeminjaman);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Peminjaman> getVerifikasiDenda() {
        List<Peminjaman> list = new ArrayList<>();
        String query = "SELECT * FROM peminjaman WHERE status_denda = 'MENUNGGU_VERIFIKASI'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Peminjaman p = new Peminjaman();
                p.setIdPeminjaman(rs.getString("id_peminjaman"));
                p.setIdPengguna(rs.getString("id_pengguna"));
                p.setBuktiPembayaran(rs.getString("bukti_pembayaran"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- PROSES LOGIN ADMIN ---
    public String[] prosesLoginAdmin(String username, String passwordInput) {
        String query = "SELECT id_admin, nama_admin, password FROM admin WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String hashDariDB = rs.getString("password");
                    if (BCrypt.checkpw(passwordInput, hashDariDB)) {
                        return new String[] { rs.getString("id_admin"), rs.getString("nama_admin") };
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================================================
    //   FUNGSI UPDATE DENDA OTOMATIS (SINKRON DENGAN PGADMIN)
    // =========================================================
    public void cekDanUpdateDendaOtomatis() {
        // Cari peminjaman yang masih "APPROVED" (belum klik tombol kembali) DAN sudah lewat batas tanggal
        String querySelect = "SELECT id_peminjaman, tanggal_kembali FROM peminjaman WHERE status_peminjaman = 'APPROVED' AND tanggal_kembali < CURRENT_DATE";
        
        // Ubah status ke DENDA secara paksa
        String queryUpdate = "UPDATE peminjaman SET status_peminjaman = 'DENDA', total_denda = ?, status_denda = 'BELUM_DIBAYAR' WHERE id_peminjaman = ?";
        
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement stmtSelect = conn.prepareStatement(querySelect);
             java.sql.ResultSet rs = stmtSelect.executeQuery()) {
             
            while (rs.next()) {
                String id = rs.getString("id_peminjaman");
                java.sql.Date tglKembali = rs.getDate("tanggal_kembali");
                
                // Hitung keterlambatan
                long selisihHari = (new java.util.Date().getTime() - tglKembali.getTime()) / (1000 * 60 * 60 * 24);
                
                if (selisihHari > 0) {
                    long totalDenda = selisihHari * 50000; // Contoh: Rp 50.000 per hari keterlambatan
                    
                    try (java.sql.PreparedStatement stmtUpdate = conn.prepareStatement(queryUpdate)) {
                        stmtUpdate.setLong(1, totalDenda);
                        stmtUpdate.setString(2, id);
                        stmtUpdate.executeUpdate();
                    }
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
    }
    
    // =========================================================
    //         KELOLA FASILITAS (TAMBAH, EDIT, HAPUS)
    // =========================================================

    public boolean tambahRuangan(String id, String nama, int kapasitas, boolean berAc, String lokasi, String gambarUrl) {
        String query = "INSERT INTO fasilitas (id_fasilitas, nama_fasilitas, is_tersedia, tipe_fasilitas, kapasitas_gedung, ber_ac, lokasi_gedung, gambar_url) VALUES (?, ?, TRUE, 'RUANGAN', ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, id); stmt.setString(2, nama); stmt.setInt(3, kapasitas); stmt.setBoolean(4, berAc); stmt.setString(5, lokasi); stmt.setString(6, gambarUrl);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean tambahAlat(String id, String nama, String jenis, String merk, String kondisi, String gambarUrl) {
        String query = "INSERT INTO fasilitas (id_fasilitas, nama_fasilitas, is_tersedia, tipe_fasilitas, jenis_alat, merk_alat, kondisi, gambar_url) VALUES (?, ?, TRUE, 'ALAT_ELEKTRONIK', ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, id); stmt.setString(2, nama); stmt.setString(3, jenis); stmt.setString(4, merk); stmt.setString(5, kondisi); stmt.setString(6, gambarUrl);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean editRuangan(String id, String nama, int kapasitas, boolean berAc, String lokasi, String gambarUrl) {
        String query = "UPDATE fasilitas SET nama_fasilitas=?, kapasitas_gedung=?, ber_ac=?, lokasi_gedung=?, gambar_url=? WHERE id_fasilitas=?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, nama); stmt.setInt(2, kapasitas); stmt.setBoolean(3, berAc); stmt.setString(4, lokasi); stmt.setString(5, gambarUrl); stmt.setString(6, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean editAlat(String id, String nama, String jenis, String merk, String kondisi, String gambarUrl) {
        String query = "UPDATE fasilitas SET nama_fasilitas=?, jenis_alat=?, merk_alat=?, kondisi=?, gambar_url=? WHERE id_fasilitas=?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, nama); stmt.setString(2, jenis); stmt.setString(3, merk); stmt.setString(4, kondisi); stmt.setString(5, gambarUrl); stmt.setString(6, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean hapusFasilitas(String idFasilitas) {
        String query = "DELETE FROM fasilitas WHERE id_fasilitas = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, idFasilitas);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // =========================================================
    //         FUNGSI BARU UNTUK BERANDA PENGGUNA
    // =========================================================

    public List<Fasilitas> getAvailableFasilitasLimit(int limit) {
        List<Fasilitas> daftarFasilitas = new ArrayList<>();
        String query = "SELECT * FROM fasilitas WHERE is_tersedia = TRUE ORDER BY RANDOM() LIMIT ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String id = rs.getString("id_fasilitas");
                    String nama = rs.getString("nama_fasilitas");
                    boolean isTersedia = rs.getBoolean("is_tersedia");
                    String tipe = rs.getString("tipe_fasilitas");
                    
                    String gambar = getAutoGambarUrl(rs.getString("gambar_url"), tipe, nama);

                    if ("RUANGAN".equals(tipe)) {
                        int kapasitas = rs.getInt("kapasitas_gedung");
                        boolean berAC = rs.getBoolean("ber_ac");
                        String lokasi = rs.getString("lokasi_gedung");
                        Ruangan r = new Ruangan(id, nama, isTersedia, kapasitas, berAC, lokasi);
                        r.setGambarUrl(gambar);
                        daftarFasilitas.add(r);
                    } else if ("ALAT_ELEKTRONIK".equals(tipe)) {
                        String jenis = rs.getString("jenis_alat");
                        String merk = rs.getString("merk_alat");
                        String kondisi = rs.getString("kondisi");
                        AlatElektronik a = new AlatElektronik(id, nama, isTersedia, jenis, merk, kondisi);
                        a.setGambarUrl(gambar);
                        daftarFasilitas.add(a);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return daftarFasilitas;
    }

    public List<Peminjaman> getRecentAktivitasByPengguna(String idPengguna) {
        List<Peminjaman> daftarAktivitas = new ArrayList<>();
        String query = "SELECT * FROM peminjaman WHERE id_pengguna = ? ORDER BY tanggal_pinjam DESC LIMIT 5";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setString(1, idPengguna);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Peminjaman p = new Peminjaman();
                    p.setIdPeminjaman(rs.getString("id_peminjaman"));
                    p.setIdFasilitas(rs.getString("id_fasilitas"));
                    p.setIdPengguna(rs.getString("id_pengguna"));
                    p.setTanggalPinjam(rs.getDate("tanggal_pinjam"));
                    p.setTanggalKembali(rs.getDate("tanggal_kembali"));
                    p.setStatusPeminjaman(rs.getString("status_peminjaman"));
                    daftarAktivitas.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return daftarAktivitas;
    }
    
    public int getJumlahReservasiSelesaiTerfilter(int bulan, int tahun) {
        int jumlah = 0;
        // bulan + 1 karena parameter bulan di Java dimulai dari 0, sedangkan SQL (PostgreSQL) dimulai dari 1
        String query = "SELECT COUNT(*) AS total FROM peminjaman WHERE status_peminjaman = 'SELESAI' AND EXTRACT(MONTH FROM tanggal_kembali) = ? AND EXTRACT(YEAR FROM tanggal_kembali) = ?";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, bulan + 1);
            stmt.setInt(2, tahun);
            try (java.sql.ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    jumlah = rs.getInt("total");
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return jumlah;
    }
}