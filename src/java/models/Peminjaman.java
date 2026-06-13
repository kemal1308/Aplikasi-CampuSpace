package models;

import java.sql.Date;
import java.sql.Time;

public class Peminjaman {
    private String idPeminjaman;
    private String idFasilitas;
    private String idPengguna;
    private Date tanggalPinjam;
    private Date tanggalKembali;
    private Time jamMulai;
    private Time jamSelesai;
    private String statusPeminjaman;
    private String buktiPembayaran;
    private String statusDenda;
    private String keperluan;


    // Kosongkan Constructor (agar 'new Peminjaman()' tidak error)
    public Peminjaman() {}

    // === GETTER & SETTER ===
    public Time getJamMulai() { return jamMulai; }
    public void setJamMulai(Time jamMulai) { this.jamMulai = jamMulai; }

    public Time getJamSelesai() { return jamSelesai; }
    public void setJamSelesai(Time jamSelesai) { this.jamSelesai = jamSelesai; }

    public String getBuktiPembayaran() { return buktiPembayaran; }
    public void setBuktiPembayaran(String buktiPembayaran) { this.buktiPembayaran = buktiPembayaran; }

    public String getStatusDenda() { return statusDenda; }
    public void setStatusDenda(String statusDenda) { this.statusDenda = statusDenda; }
    
    public String getIdPeminjaman() { return idPeminjaman; }
    public void setIdPeminjaman(String idPeminjaman) { this.idPeminjaman = idPeminjaman; }

    public String getIdFasilitas() { return idFasilitas; }
    public void setIdFasilitas(String idFasilitas) { this.idFasilitas = idFasilitas; }

    public String getIdPengguna() { return idPengguna; }
    public void setIdPengguna(String idPengguna) { this.idPengguna = idPengguna; }

    public Date getTanggalPinjam() { return tanggalPinjam; }
    public void setTanggalPinjam(Date tanggalPinjam) { this.tanggalPinjam = tanggalPinjam; }

    public Date getTanggalKembali() { return tanggalKembali; }
    public void setTanggalKembali(Date tanggalKembali) { this.tanggalKembali = tanggalKembali; }

    public String getStatusPeminjaman() { return statusPeminjaman; }
    public void setStatusPeminjaman(String statusPeminjaman) { this.statusPeminjaman = statusPeminjaman; }

    public String getKeperluan() { return keperluan; }
    public void setKeperluan(String keperluan) { this.keperluan = keperluan; }
}