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

@WebServlet(name = "KelolaFasilitasServlet", urlPatterns = {"/KelolaFasilitasServlet"})
public class KelolaFasilitasServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String aksi = request.getParameter("aksi"); // "tambah", "edit", atau "hapus"
        DataManager dm = new DataManager();
        boolean sukses = false;

        if ("hapus".equals(aksi)) {
            String idFasilitas = request.getParameter("id_fasilitas");
            sukses = dm.hapusFasilitas(idFasilitas);
        } else {
            String tipe = request.getParameter("tipe_fasilitas");
            String idFasilitas = request.getParameter("id_fasilitas");
            String namaFasilitas = request.getParameter("nama_fasilitas");
            String gambarUrl = request.getParameter("gambar_url");

            if ("RUANGAN".equals(tipe)) {
                int kapasitas = Integer.parseInt(request.getParameter("kapasitas"));
                boolean berAc = request.getParameter("ber_ac") != null;
                String lokasi = request.getParameter("lokasi");
                
                if ("tambah".equals(aksi)) sukses = dm.tambahRuangan(idFasilitas, namaFasilitas, kapasitas, berAc, lokasi, gambarUrl);
                else if ("edit".equals(aksi)) sukses = dm.editRuangan(idFasilitas, namaFasilitas, kapasitas, berAc, lokasi, gambarUrl);
                
            } else if ("ALAT_ELEKTRONIK".equals(tipe)) {
                String jenis = request.getParameter("jenis_alat");
                String merk = request.getParameter("merk_alat");
                String kondisi = request.getParameter("kondisi");
                
                if ("tambah".equals(aksi)) sukses = dm.tambahAlat(idFasilitas, namaFasilitas, jenis, merk, kondisi, gambarUrl);
                else if ("edit".equals(aksi)) sukses = dm.editAlat(idFasilitas, namaFasilitas, jenis, merk, kondisi, gambarUrl);
            }
        }
        
        response.sendRedirect("admin/dashboard.jsp?menu=fasilitas&status=" + (sukses ? "berhasil" : "gagal"));
    }
}
