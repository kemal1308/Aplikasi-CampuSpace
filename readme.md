# CampuSpace

CampuSpace adalah sebuah aplikasi berbasis Java Web (JSP & Servlet) yang dirancang untuk mendigitalkan dan mempermudah proses peminjaman fasilitas di lingkungan kampus. 

Aplikasi ini dikembangkan sebagai bagian dari Tugas Besar mata kuliah Pemrograman Berorientasi Objek (PBO) pada program studi Informatika, Telkom University.

## Latar Belakang & Tujuan
Sistem peminjaman fasilitas kampus yang manual seringkali memicu bentrok jadwal, ketidakjelasan status peminjaman, dan sulitnya melacak denda keterlambatan. Tujuan utama dari pengembangan CampuSpace adalah:
* Memberikan platform terpusat bagi mahasiswa dan dosen untuk mengecek ketersediaan dan mereservasi ruangan atau alat elektronik.
* Mempermudah administrator dalam mengelola persetujuan (approval) peminjaman.
* Mengotomatisasi sistem denda keterlambatan pengembalian beserta verifikasi pembayarannya.
* Mengimplementasikan konsep Pemrograman Berorientasi Objek (OOP) secara langsung ke dalam studi kasus nyata berbasis web.

## Fitur Utama

**Sisi Pengguna (Mahasiswa & Dosen):**
* **Katalog Interaktif:** Pencarian fasilitas (ruangan dan alat) lengkap dengan filter kategori dan lokasi gedung.
* **Reservasi Fasilitas:** Pengajuan tanggal pinjam dan kembali secara sistematis.
* **Jadwal Peminjamanku:** Kalender visual untuk melacak status peminjaman saat ini, riwayat, dan tenggat waktu pengembalian.
* **Sistem Denda:** Notifikasi otomatis jika terlambat mengembalikan fasilitas dan fitur unggah resi bukti pembayaran denda.

**Sisi Administrator:**
* **Dashboard Monitoring:** Visualisasi data okupansi fasilitas (persentase ruangan dan alat yang sedang dipakai).
* **Persetujuan (Approval):** Fitur untuk menyetujui atau menolak pengajuan peminjaman baru, serta memverifikasi bukti transfer denda.
* **Manajemen Fasilitas:** Operasi CRUD (Create, Read, Update, Delete) untuk mendata ruangan kelas, auditorium, alat elektronik.
* **Laporan & Log Transaksi:** Perekaman seluruh riwayat aktivitas yang bisa difilter berdasarkan status (termasuk status Selesai), bulan, dan tahun.

## Teknologi yang Digunakan
* **Backend:** Java (JSP & Servlet)
* **Frontend:** HTML5, Tailwind CSS
* **Database:** PostgreSQL (pgAdmin)
* **Keamanan:** BCrypt (`jbcrypt-0.4.jar`) untuk hashing password
* **Web Server:** Apache Tomcat
* **IDE:** Apache NetBeans

## Tim Pengembang
* Kemal Farouq At-Tirmidzi
* Ranzyah Adinata Aldo
* Shasha Shany Azahra
* Ihsan Dwika Putra

## Cara Instalasi & Menjalankan Project

**1. Persiapan Database**
* Pastikan PostgreSQL dan pgAdmin sudah terinstal di komputer.
* Buat database baru bernama `campuspace` di pgAdmin.
* Jalankan query SQL dari file skema database yang ada di folder project ini untuk membuat tabel.

**2. Persiapan NetBeans**
* Buka aplikasi NetBeans, pilih **Open Project** dan pilih folder CampuSpace.
* Buka file `src/java/controllers/DatabaseConnection.java` dan sesuaikan `PASSWORD` dengan password pgAdmin milikmu.

**3. Konfigurasi Library**
* Pastikan file driver PostgreSQL (`postgresql-42.x.x.jar`) dan BCrypt (`jbcrypt-0.4.jar`) sudah berada di dalam folder `Web Pages/WEB-INF/lib/`.

**4. Menjalankan Aplikasi**
* Klik kanan pada project CampuSpace di NetBeans, pilih **Clean and Build**.
* Setelah sukses, klik tombol **Run**. Browser akan otomatis terbuka menampilkan halaman login.