/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

/**
 *
 * @author Ihsan
 */

public class Dosen extends Peminjam {
    private String nidn;
    private String jabatan;

    public Dosen(String namaPengguna, String idPengguna, String nidn, String jabatan) {
        // Super memanggil constructor Peminjam (max 7 hari, max 5 item)
        super(namaPengguna, idPengguna, 7, 5);
        this.nidn = nidn;
        this.jabatan = jabatan;
    }

    @Override
    public String getProfil() {
        return "Dosen: " + namaPengguna + " (NIDN: " + nidn + ", Jabatan: " + jabatan + ")";
    }
}
