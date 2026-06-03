/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Pastikan kamu sudah menambahkan library jBCrypt ke dalam project NetBeans kamu
import org.mindrot.jbcrypt.BCrypt; 

@WebServlet(name = "AdminLoginServlet", urlPatterns = {"/AdminLoginServlet"})
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Menangkap inputan dari form login
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        boolean isLoginValid = false;
        String idAdmin = "";
        String namaAdmin = "";

        try {
            // Membuka koneksi ke database
            Connection conn = DatabaseConnection.getConnection();
            
            // Query untuk mencari admin berdasarkan username
            String sql = "SELECT id_admin, password, nama_admin FROM admin WHERE username = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, user);
            
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                // Mengambil password hash ($2a$10$...) dari database
                String dbPasswordHash = rs.getString("password");
                
                // Membandingkan password inputan ("123456") dengan password hash di database
                if (BCrypt.checkpw(pass, dbPasswordHash)) {
                    isLoginValid = true;
                    idAdmin = rs.getString("id_admin");
                    namaAdmin = rs.getString("nama_admin");
                }
            }
            
            rs.close();
            pst.close();
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Arahkan halaman sesuai hasil validasi
        if (isLoginValid) {
            // Jika sukses, buat sesi (Session)
            HttpSession session = request.getSession();
            session.setAttribute("idAdmin", idAdmin);
            session.setAttribute("namaAdmin", namaAdmin);
            session.setAttribute("userAktif", namaAdmin);
            session.setAttribute("idPengguna", idAdmin); 
            session.setAttribute("roleAktif", "ADMIN");
            
            // Redirect ke Dashboard Admin
            response.sendRedirect("admin/dashboard.jsp");
        } else {
            // Jika gagal, kembalikan ke halaman login dengan parameter error
            response.sendRedirect("admin_login.jsp?error=invalid");
        }
    }
}