/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controllers;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "UploadResiServlet", urlPatterns = {"/UploadResiServlet"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UploadResiServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idPeminjaman = request.getParameter("id_peminjaman");
        Part filePart = request.getPart("foto_resi");
        
        // Buat folder 'uploads' jika belum ada di dalam server
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Dapatkan nama file dan simpan
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName; // Cegah nama kembar
        filePart.write(uploadPath + File.separator + uniqueFileName);

        // Update ke Database
        DataManager dm = new DataManager();
        boolean sukses = dm.uploadBuktiTransfer(idPeminjaman, uniqueFileName);

        if (sukses) {
            response.sendRedirect("user/peminjamanku.jsp?status=upload_sukses");
        } else {
            response.sendRedirect("user/peminjamanku.jsp?status=upload_gagal");
        }
    }
}