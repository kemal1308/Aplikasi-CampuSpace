CREATE TABLE manager (
    id_manager VARCHAR(50) PRIMARY KEY, -- [cite: 147]
    nama_manager VARCHAR(100) NOT NULL, -- [cite: 146]
    data_file VARCHAR(255)              -- [cite: 148]
);

-- 3. Membuat Tabel Pengguna (Menggabungkan Class Peminjam, Mahasiswa, dan Dosen)
CREATE TABLE pengguna (
    id_pengguna VARCHAR(50) PRIMARY KEY, -- [cite: 318]
    nama_pengguna VARCHAR(100) NOT NULL, -- [cite: 318]
    tipe_pengguna VARCHAR(20) NOT NULL,  -- Penanda: 'MAHASISWA' atau 'DOSEN'
    max_pinjam INT NOT NULL,             -- [cite: 318]
    max_item INT NOT NULL,               -- [cite: 318]
    
    -- Atribut khusus (Bisa NULL tergantung tipe_pengguna)
    nim VARCHAR(50),                     -- [cite: 322]
    nidn VARCHAR(50),                    -- [cite: 322]
    jabatan VARCHAR(100)                 -- [cite: 322]
);

-- 4. Membuat Tabel Fasilitas (Menggabungkan Class Fasilitas, Ruangan, dan AlatElektronik)
CREATE TABLE fasilitas (
    id_fasilitas VARCHAR(50) PRIMARY KEY, -- [cite: 311]
    nama_fasilitas VARCHAR(100) NOT NULL, -- [cite: 311]
    is_tersedia BOOLEAN DEFAULT TRUE,     -- [cite: 311]
    tipe_fasilitas VARCHAR(20) NOT NULL,  -- Penanda: 'RUANGAN' atau 'ALAT_ELEKTRONIK'
    
    -- Atribut khusus Ruangan
    kapasitas_gedung INT,                 -- [cite: 313]
    ber_ac BOOLEAN,                       -- [cite: 313]
    lokasi_gedung VARCHAR(100),           -- [cite: 313]
    
    -- Atribut khusus Alat Elektronik
    jenis_alat VARCHAR(50),               -- [cite: 316]
    merk_alat VARCHAR(50),                -- [cite: 316]
    kondisi VARCHAR(50)                   -- [cite: 316]
);

-- 5. Membuat Tabel Peminjaman (Menghubungkan Pengguna dan Fasilitas)
CREATE TABLE peminjaman (
    id_peminjaman VARCHAR(50) PRIMARY KEY, -- [cite: 331]
    id_fasilitas VARCHAR(50) NOT NULL,     -- [cite: 331]
    id_pengguna VARCHAR(50) NOT NULL,      -- [cite: 331]
    tanggal_pinjam DATE NOT NULL,          -- [cite: 331]
    tanggal_kembali DATE NOT NULL,         -- [cite: 331]
    status_peminjaman VARCHAR(20) DEFAULT 'Aktif', -- [cite: 331]
    total_denda NUMERIC(10, 2) DEFAULT 0,
    
    -- Membuat relasi antar tabel (Foreign Key)
    CONSTRAINT fk_fasilitas
        FOREIGN KEY(id_fasilitas) 
        REFERENCES fasilitas(id_fasilitas)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_pengguna
        FOREIGN KEY(id_pengguna) 
        REFERENCES pengguna(id_pengguna)
        ON DELETE CASCADE
);

-- 1. Masukkan 1 Data Manager (Sebagai Pelengkap)
INSERT INTO manager (id_manager, nama_manager, data_file)
VALUES 
('MGR-001', 'Admin', 'data_admin.json');

-- 2. Masukkan 5 Data Pengguna (4 Mahasiswa, 1 Dosen)
INSERT INTO pengguna (id_pengguna, nama_pengguna, tipe_pengguna, max_pinjam, max_item, nim, nidn, jabatan)
VALUES 
('MHS-001', 'Kemal Farouq At-Tirmidzi', 'MAHASISWA', 3, 2, '103012400283', NULL, NULL),
('MHS-002', 'Shasha Shany Azahra', 'MAHASISWA', 3, 2, '103012400168', NULL, NULL),
('MHS-003', 'Ranzyah Adinata', 'MAHASISWA', 3, 2, '103012430015', NULL, NULL),
('MHS-004', 'Ihsan Dwika Putra', 'MAHASISWA', 3, 2, '103012400129', NULL, NULL),
('DSN-001', 'Dr. Budi Dosen OOP', 'DOSEN', 7, 5, NULL, '1122334455', 'Lektor Kep');

-- 3. Masukkan 5 Data Fasilitas (3 Ruangan, 2 Alat Elektronik)
INSERT INTO fasilitas (id_fasilitas, nama_fasilitas, is_tersedia, tipe_fasilitas, kapasitas_gedung, ber_ac, lokasi_gedung, jenis_alat, merk_alat, kondisi)
VALUES 
('RGN-001', 'Kelas TULT 06.04', TRUE, 'RUANGAN', 40, TRUE, 'Gedung TULT', NULL, NULL, NULL),
('RGN-002', 'Laboratorium Komputer A', FALSE, 'RUANGAN', 30, TRUE, 'Gedung Fakultas Informatika', NULL, NULL, NULL),
('RGN-003', 'Aula Utama', TRUE, 'RUANGAN', 200, TRUE, 'Gedung Serba Guna', NULL, NULL, NULL),
('ALT-001', 'Proyektor Ruang Rapat', TRUE, 'ALAT_ELEKTRONIK', NULL, NULL, NULL, 'Proyektor', 'Epson', 'Baik'),
('ALT-002', 'Microphone Wireless', TRUE, 'ALAT_ELEKTRONIK', NULL, NULL, NULL, 'Microphone', 'Shure', 'Baik');

-- 4. Masukkan 2 Data Peminjaman (Sebagai Contoh Transaksi)
-- Contoh: Kemal meminjam Laboratorium Komputer A (status fasilitas dibuat FALSE di atas)
INSERT INTO peminjaman (id_peminjaman, id_fasilitas, id_pengguna, tanggal_pinjam, tanggal_kembali, status_peminjaman, total_denda)
VALUES 
('TRX-001', 'RGN-002', 'MHS-001', '2026-05-25', '2026-05-28', 'Aktif', 0),
('TRX-002', 'ALT-001', 'DSN-001', '2026-05-20', '2026-05-22', 'Selesai', 0);
