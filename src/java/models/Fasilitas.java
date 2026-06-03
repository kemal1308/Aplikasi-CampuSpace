/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

public class Fasilitas {
    protected String idFasilitas;
    protected String namaFasilitas;
    protected boolean isTersedia;
    protected String gambarUrl;

    public Fasilitas(String idFasilitas, String namaFasilitas, boolean isTersedia) {
        this.idFasilitas = idFasilitas;
        this.namaFasilitas = namaFasilitas;
        this.isTersedia = isTersedia;
    }

    // Fungsi Getter yang dicari oleh JSP
    public String getIdFasilitas() {
        return idFasilitas;
    }

    public String getNamaFasilitas() {
        return namaFasilitas;
    }

    public boolean isTersedia() {
        return isTersedia;
    }
    
    public String getGambarUrl() { return gambarUrl; }
    public void setGambarUrl(String gambarUrl) { this.gambarUrl = gambarUrl; }
}