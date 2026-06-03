/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

/**
 *
 * @author Ihsan
 */

public abstract class Peminjam {
    protected String namaPengguna;
    protected String idPengguna;
    private int maxPinjam;
    private int maxItem;

    public Peminjam(String namaPengguna, String idPengguna, int maxPinjam, int maxItem) {
        this.namaPengguna = namaPengguna;
        this.idPengguna = idPengguna;
        this.maxPinjam = maxPinjam;
        this.maxItem = maxItem;
    }

    public int getMaxPinjam() {
        return this.maxPinjam;
    }
    
    public int getMaxItem() {
        return this.maxItem;
    }

    // Abstract method wajib di-override
    public abstract String getProfil();
}
