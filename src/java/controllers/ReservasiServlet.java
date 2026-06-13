/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
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
        
        HttpSession session = request.getSession();
        String idPengguna = (String) session.getAttribute("idPengguna");
        
        if (idPengguna == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idFasilitas = request.getParameter("id_fasilitas");

        try {
            String tglPinjamStr = request.getParameter("tgl_pinjam");
            String tglKembaliStr = request.getParameter("tgl_kembali");
            String keperluan = request.getParameter("keperluan"); 
            String tipeWaktu = request.getParameter("tipe_waktu");
            
            if (idFasilitas == null || idFasilitas.trim().isEmpty() || 
                tglPinjamStr == null || tglPinjamStr.trim().isEmpty() || 
                tglKembaliStr == null || tglKembaliStr.trim().isEmpty()) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_input");
                return;
            }

            LocalDate tglPinjamLocal = LocalDate.parse(tglPinjamStr);
            LocalDate tglKembaliLocal = LocalDate.parse(tglKembaliStr);
            LocalDate hariIni = LocalDate.now();

            // Semua tipe waktu wajib H-1
            if (!tglPinjamLocal.isAfter(hariIni)) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_h1");
                return;
            }

            long durasiPinjam = ChronoUnit.DAYS.between(tglPinjamLocal, tglKembaliLocal);
            DataManager dm = new DataManager();
            int maxHari = dm.getMaxPinjam(idPengguna); 

            if (durasiPinjam > maxHari) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_durasi&max=" + maxHari);
                return; 
            }
            if (durasiPinjam < 0) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_tanggal_mundur");
                return; 
            }

            String strJamMulai = "";
            String strJamSelesai = "";

            if ("seharian".equals(tipeWaktu)) {
                strJamMulai = "07:00:00";
                strJamSelesai = "21:00:00";
            } else {
                strJamMulai = request.getParameter("jam_mulai");
                strJamSelesai = request.getParameter("jam_selesai");

                if (strJamMulai == null || strJamMulai.isEmpty() || strJamSelesai == null || strJamSelesai.isEmpty()) {
                    response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_input");
                    return;
                }
                
                if (strJamMulai.length() == 5) strJamMulai += ":00";
                if (strJamSelesai.length() == 5) strJamSelesai += ":00";
                
                if (Time.valueOf(strJamSelesai).before(Time.valueOf(strJamMulai))) {
                    response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_jam_mundur");
                    return;
                }
            }
            
            // CEK BENTROK: Memisahkan tanggal dan jam agar tidak terikat sebagai satu timeline panjang
            String jadwalBentrok = dm.cekKetersediaanJadwal(idFasilitas, tglPinjamStr, tglKembaliStr, strJamMulai, strJamSelesai);
            if (jadwalBentrok != null) {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_bentrok&tgl=" + java.net.URLEncoder.encode(jadwalBentrok, "UTF-8"));
                return; 
            }

            String idPeminjaman = "RES-" + System.currentTimeMillis();
            boolean sukses = dm.simpanReservasi(idPeminjaman, idFasilitas, idPengguna, tglPinjamStr, tglKembaliStr, keperluan, strJamMulai, strJamSelesai);

            if (sukses) {
                response.sendRedirect("user/peminjamanku.jsp?status=sukses_reservasi");
            } else {
                response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_database");
            }

        } catch (java.time.format.DateTimeParseException e) {
            e.printStackTrace();
            response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_format_tanggal");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("user/reservasi.jsp?id=" + idFasilitas + "&status=error_sistem");
        }
    }
}