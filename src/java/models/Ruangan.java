/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

public class Ruangan extends Fasilitas {
    private int kapasitas;
    private boolean berAc;
    private String lokasiGedung;

    public Ruangan(String idFasilitas, String namaFasilitas, boolean isTersedia, int kapasitas, boolean berAc, String lokasiGedung) {
        super(idFasilitas, namaFasilitas, isTersedia);
        this.kapasitas = kapasitas;
        this.berAc = berAc;
        this.lokasiGedung = lokasiGedung;
    }

    public int getKapasitas() { return kapasitas; }
    public void setKapasitas(int kapasitas) { this.kapasitas = kapasitas; }

    public boolean isBerAc() { return berAc; }
    public void setBerAc(boolean berAc) { this.berAc = berAc; }

    public String getLokasiGedung() { return lokasiGedung; }
    public void setLokasiGedung(String lokasiGedung) { this.lokasiGedung = lokasiGedung; }
}