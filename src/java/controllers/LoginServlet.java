/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Tangkap inputan dari form
        String username = request.getParameter("username"); 
        String role = request.getParameter("role");         
        
        // Validasi kosong
        if (username == null || username.trim().isEmpty() || role == null) {
            response.sendRedirect("login.jsp"); // Kembalikan ke halaman login
            return;
        }

        // ==========================================
        // LOGIKA VALIDASI DOMAIN EMAIL INSTITUSI
        // ==========================================
        if (role.equalsIgnoreCase("Mahasiswa")) {
            // Syarat mutlak mahasiswa: @student.telkomuniversity.ac.id
            if (!username.endsWith("@student.telkomuniversity.ac.id")) {
                response.sendRedirect("login.jsp?error=domain_mhs");
                return; // Hentikan proses jika domain salah
            }
        } 
        else if (role.equalsIgnoreCase("Dosen") || role.equalsIgnoreCase("Pegawai")) {
            // Syarat mutlak dosen/pegawai: @telkomuniversity.ac.id
            if (!username.endsWith("@telkomuniversity.ac.id")) {
                response.sendRedirect("login.jsp?error=domain_dosen");
                return; // Hentikan proses jika domain salah
            }
        }
        // ==========================================

        // 2. Panggil DataManager untuk melakukan proses JIT (Cek & Daftar Otomatis)
        DataManager dm = new DataManager();
        String[] userData = dm.prosesLoginSSO(username, role);

        if (userData != null) {
            // 3. Jika berhasil (baik user lama maupun user baru didaftarkan), simpan Sesi!
            HttpSession session = request.getSession();
            session.setAttribute("idPengguna", userData[0]); // Penting untuk ReservasiServlet nanti!
            session.setAttribute("userAktif", userData[1]);  // Nama Pengguna
            session.setAttribute("roleAktif", userData[2]);  // Role (MAHASISWA/DOSEN)

            // 4. Arahkan ke beranda
            response.sendRedirect("user/beranda.jsp");
        } else {
            // Jika database error / gagal terhubung
            response.sendRedirect("login.jsp?error=database");
        }
    }
}