/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import models.Fasilitas;

@WebServlet(name = "KatalogServlet", urlPatterns = {"/katalog"})
public class KatalogServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Ambil data dari database melalui DataManager
        DataManager dataManager = new DataManager();
        List<Fasilitas> daftarFasilitas = dataManager.getAllFasilitas();
        
        // 2. Simpan list ke dalam request attribute agar bisa dibaca di JSP
        request.setAttribute("daftarFasilitas", daftarFasilitas);
        
        // 3. Lempar halaman secara internal ke folder user/katalog.jsp
        request.getRequestDispatcher("user/katalog.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}