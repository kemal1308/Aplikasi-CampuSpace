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

@WebServlet(name = "ApprovalServlet", urlPatterns = {"/ApprovalServlet"})
public class ApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Tangkap parameter sesuai dengan input name di dashboard.jsp
        String idPeminjaman = request.getParameter("id_peminjaman");
        String aksi = request.getParameter("aksi");
        
        // Validasi aman jika parameter kosong
        if (idPeminjaman == null || aksi == null) {
            response.sendRedirect("admin/dashboard.jsp");
            return;
        }

        DataManager dm = new DataManager();
        boolean berhasil = false;

        // 2. Gunakan equalsIgnoreCase agar aman dari typo huruf besar/kecil
        if (aksi.equalsIgnoreCase("approve")) {
            // Ubah status menjadi APPROVED agar bisa memicu trigger denda otomatis
            berhasil = dm.updateStatusPeminjaman(idPeminjaman, "APPROVED");
        } 
        else if (aksi.equalsIgnoreCase("reject")) {
            berhasil = dm.updateStatusPeminjaman(idPeminjaman, "REJECTED");
        }
        else if (aksi.equalsIgnoreCase("lunas")) {
            // Untuk verifikasi denda pembayaran
            berhasil = dm.verifikasiDendaSelesai(idPeminjaman);
        }

        // 3. Kembalikan Admin ke halaman dashboard setelah memproses
        if (berhasil) {
            // Berhasil update db
            response.sendRedirect("admin/dashboard.jsp?status=success");
        } else {
            // Gagal update db
            response.sendRedirect("admin/dashboard.jsp?status=failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
