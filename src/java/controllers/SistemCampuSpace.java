/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import java.util.List;
import models.Fasilitas;

public class SistemCampuSpace {
    public static void main(String[] args) {
        System.out.println("=== Memulai Pengujian Integrasi CampuSpace ===\n");
        
        DataManager dm = new DataManager();
        List<Fasilitas> katalog = dm.getAllFasilitas();
        
        if (katalog.isEmpty()) {
            System.out.println("Data fasilitas kosong atau koneksi database gagal.");
        } else {
            System.out.println("Daftar Fasilitas di Database:");
            for (Fasilitas f : katalog) {
                // Method disesuaikan: menggunakan getNamaFasilitas() dan isTersedia()
                System.out.println("- [" + f.getIdFasilitas() + "] " + f.getNamaFasilitas() + 
                                   " | Status: " + (f.isTersedia() ? "Tersedia" : "Dipinjam"));
            }
        }
    }
}