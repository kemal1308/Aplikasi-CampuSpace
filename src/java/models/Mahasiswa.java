/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

/**
 *
 * @author Ihsan
 */

public class Mahasiswa extends Peminjam {
    private String nim;

    public Mahasiswa(String namaPengguna, String idPengguna, String nim) {
        // Super memanggil constructor Peminjam (max 3 hari, max 2 item)
        super(namaPengguna, idPengguna, 3, 2); 
        this.nim = nim;
    }

    @Override
    public String getProfil() {
        return "Mahasiswa: " + namaPengguna + " (NIM: " + nim + ")";
    }
}
