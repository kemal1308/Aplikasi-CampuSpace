/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:postgresql://localhost:5432/CampuSpace";
    private static final String USER = "postgres";
    // UBAH PASSWORD DI BAWAH INI SESUAIKAN DENGAN PGADMIN KAMU
    private static final String PASSWORD = "12345."; 

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL belum ditambahkan ke Libraries!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Gagal terhubung ke Database PostgreSQL!");
            e.printStackTrace();
        }
        return conn;
    }
}