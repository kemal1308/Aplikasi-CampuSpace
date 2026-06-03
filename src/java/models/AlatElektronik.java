/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

public class AlatElektronik extends Fasilitas {
    private String jenisAlat;
    private String merkAlat;
    private String kondisi;

    public AlatElektronik(String idFasilitas, String namaFasilitas, boolean isTersedia, String jenisAlat, String merkAlat, String kondisi) {
        super(idFasilitas, namaFasilitas, isTersedia);
        this.jenisAlat = jenisAlat;
        this.merkAlat = merkAlat;
        this.kondisi = kondisi;
    }

    public String getJenisAlat() { return jenisAlat; }
    public void setJenisAlat(String jenisAlat) { this.jenisAlat = jenisAlat; }

    public String getMerkAlat() { return merkAlat; }
    public void setMerkAlat(String merkAlat) { this.merkAlat = merkAlat; }

    public String getKondisi() { return kondisi; }
    public void setKondisi(String kondisi) { this.kondisi = kondisi; }
}
