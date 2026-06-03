/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ReservasiServlet", urlPatterns = {"/ReservasiServlet"})
public class ReservasiServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Validasi Sesi Pengguna
        HttpSession session = request.getSession();
        String idPengguna = (String) session.getAttribute("idPengguna");
        
        if (idPengguna == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idFasilitas = request.getParameter("id_fasilitas");

        try {
            // 2. Ambil Parameter Tanggal dan Keperluan dari Form HTML
            String tglPinjamStr = request.getParameter("tgl_pinjam");
            String tglKembaliStr = request.getParameter("tgl_kembali");
            String keperluan = request.getParameter("keperluan"); // <-- MENANGKAP PARAMETER KEPERLUAN
            
            // Validasi Input Kosong
            if (idFasilitas == null || idFasilitas.trim().isEmpty() || 
                tglPinjamStr == null || tglPinjamStr.trim().isEmpty() || 
                tglKembaliStr == null || tglKembaliStr.trim().isEmpty()) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_input");
                return;
            }

            // ==========================================================
            // LOGIKA PEMBATASAN DURASI PINJAM
            // ==========================================================
            // Ubah string tanggal ke format LocalDate Java untuk menghitung selisih hari
            LocalDate tglPinjamLocal = LocalDate.parse(tglPinjamStr);
            LocalDate tglKembaliLocal = LocalDate.parse(tglKembaliStr);
            
            // Hitung durasi (selisih hari)
            long durasiPinjam = ChronoUnit.DAYS.between(tglPinjamLocal, tglKembaliLocal);
            
            // Ambil jatah maksimal hari berdasarkan Role User dari database
            DataManager dm = new DataManager();
            int maxHari = dm.getMaxPinjam(idPengguna); 

            // Cek Aturan 1: Apakah durasi melebihi batas jatah role?
            if (durasiPinjam > maxHari) {
                // Tolak dan kembalikan ke form dengan pesan error durasi
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_durasi&max=" + maxHari);
                return; 
            }
            
            // Cek Aturan 2: Tanggal kembali tidak boleh sebelum tanggal pinjam (Time Travel)
            if (durasiPinjam < 0) {
                // Tolak dan kembalikan ke form dengan pesan error tanggal terbalik
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_tanggal_mundur");
                return; 
            }
            // ==========================================================

           // 3. Konversi format LocalDate ke java.sql.Date untuk Database SQL
            Date sqlTglPinjam = Date.valueOf(tglPinjamLocal);
            Date sqlTglKembali = Date.valueOf(tglKembaliLocal);

            // ==========================================================
            // 4. CEK ATURAN 3: VALIDASI BENTROK JADWAL & H-1 STERILISASI
            // ==========================================================
            String jadwalBentrok = dm.cekKetersediaanJadwal(idFasilitas, sqlTglPinjam, sqlTglKembali);
            if (jadwalBentrok != null) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_bentrok&tgl=" + java.net.URLEncoder.encode(jadwalBentrok, "UTF-8"));
                return; // Hentikan eksekusi, kembalikan user!
            }

            // 5. Generate ID Peminjaman unik
            String idPeminjaman = "RES-" + System.currentTimeMillis();

            // 6. Simpan ke Database dengan menyertakan variabel keperluan
            boolean sukses = dm.simpanReservasi(idPeminjaman, idFasilitas, idPengguna, sqlTglPinjam, sqlTglKembali, keperluan);

            // 6. Arahkan Halaman Berdasarkan Hasil
            if (sukses) {
                response.sendRedirect("user/peminjamanku.jsp?status=sukses_reservasi");
            } else {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_database");
            }

        } catch (java.time.format.DateTimeParseException e) {
            // Jika browser mengirim format tanggal yang tidak valid
            e.printStackTrace();
            response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_format_tanggal");
        } catch (Exception e) {
            // Jika ada error internal sistem lainnya
            e.printStackTrace();
            response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_sistem");
        }
    }
}