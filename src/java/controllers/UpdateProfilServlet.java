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

@WebServlet(name = "UpdateProfilServlet", urlPatterns = {"/UpdateProfilServlet"})
public class UpdateProfilServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String idPengguna = (String) session.getAttribute("idPengguna");
        
        if (idPengguna == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String nimBaru = request.getParameter("nim");
        
        if (nimBaru != null && !nimBaru.trim().isEmpty()) {
            DataManager dm = new DataManager();
            boolean sukses = dm.updateNimPengguna(idPengguna, nimBaru);
            
            if (sukses) {
                // --- INI YANG BARU: Simpan NIM ke memori sesi agar langsung tampil di layar ---
                session.setAttribute("nimAktif", nimBaru);
                
                response.sendRedirect("user/pengaturan.jsp?status=sukses");
            } else {
                response.sendRedirect("user/pengaturan.jsp?status=gagal");
            }
        } else {
            response.sendRedirect("user/pengaturan.jsp?status=kosong");
        }
    }
}