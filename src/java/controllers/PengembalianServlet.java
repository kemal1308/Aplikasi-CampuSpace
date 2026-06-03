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

@WebServlet(name = "PengembalianServlet", urlPatterns = {"/PengembalianServlet"})
public class PengembalianServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idPeminjaman = request.getParameter("id_peminjaman");
        
        // Pastikan ID tidak kosong
        if (idPeminjaman != null && !idPeminjaman.trim().isEmpty()) {
            DataManager dm = new DataManager();
            
            // Mengubah status peminjaman menjadi DIKEMBALIKAN agar Admin bisa melihatnya
            boolean sukses = dm.updateStatusPeminjaman(idPeminjaman, "DIKEMBALIKAN");
            
            if (sukses) {
                // Berhasil update, kembalikan ke halaman jadwal dengan parameter sukses
                response.sendRedirect("user/peminjamanku.jsp?status=sukses_kembali");
                return;
            }
        }
        
        // Jika gagal
        response.sendRedirect("user/peminjamanku.jsp?status=error_sistem");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
