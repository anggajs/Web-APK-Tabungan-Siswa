CREATE database db_tabsis;
USE db_tabsis;

CREATE TABLE `tb_kelas` (
  `id_kelas` int(11) PRIMARY KEY AUTO_INCREMENT,
  `kelas` varchar(20) NOT NULL
);

CREATE TABLE `tb_siswa` (
  `nis` char(12) PRIMARY KEY,
  `nama_siswa` varchar(40) NOT NULL,
  `jekel` enum('LK','PR') NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `status` enum('Aktif','Lulus','Pindah') NOT NULL,
  `th_masuk` year(4) NOT NULL,
  FOREIGN KEY (`id_kelas`) REFERENCES `tb_kelas` (`id_kelas`)
);

CREATE TABLE `tb_tabungan` (
  `id_tabungan` int(11) PRIMARY KEY AUTO_INCREMENT,
  `nis` char(12) NOT NULL,
  `setor` int(11) NOT NULL,
  `tarik` int(11) NOT NULL,
  `tgl` date NOT NULL,
  `jenis` enum('ST','TR') NOT NULL,
  `petugas` varchar(20) NOT NULL,
  FOREIGN KEY (`nis`) REFERENCES `tb_siswa` (`nis`)
);

CREATE TABLE `tb_pengguna` (
  `id_pengguna` int(11)  PRIMARY KEY AUTO_INCREMENT,
  `nama_pengguna` varchar(20) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(15) NOT NULL,
  `level` enum('Administrator','Petugas') NOT NULL
);

-- Menyisipkan data pada tabel tb_siswa
INSERT INTO tb_siswa (nis, nama_siswa, jekel, id_kelas, status, th_masuk)
VALUES ('200946332124', 'Dwi', 'PR', 1, 'Aktif', 2021);

-- Menyisipkan data pada tabel tb_kelas
INSERT INTO tb_kelas (kelas)
VALUES ('Kelas 16');

-- Menyisipkan data pada tabel tb_tabungan
INSERT INTO tb_tabungan (nis, setor, tarik, tgl, jenis, petugas)
VALUES ('200946332124', 300000, 0, '2023-05-26', 'ST', 'Jane');



-- siswa aktif --
CREATE VIEW siswaaktif AS SELECT
* from tb_siswa where status='Aktif';

-- drop view siswaaktif ;

-- tariksaldo siswa --
CREATE VIEW tariksaldo_siswa AS
SELECT s.nis, s.nama_siswa, t.id_tabungan, t.tarik, t.tgl, t.petugas 
FROM tb_siswa s
JOIN tb_tabungan t ON s.nis = t.nis 
WHERE jenis = 'TR' 
ORDER BY tgl DESC, id_tabungan DESC;

-- DROP VIEW tariksaldo_siswa ;

-- setor siswa --
CREATE VIEW setor_siswa AS
SELECT s.nis, s.nama_siswa, t.id_tabungan, t.setor, t.tgl, t.petugas 
FROM tb_siswa s
JOIN tb_tabungan t ON s.nis = t.nis 
WHERE jenis = 'ST' 
ORDER BY tgl DESC, id_tabungan DESC;

 
--  drop view setor_siswa;

-- TAMBAH DATA SISWA --
DELIMITER //
CREATE PROCEDURE addsiswa (
	IN dnis VARCHAR (20),
    IN dnama VARCHAR (50),
    IN djk VARCHAR (10),
    IN idk INT (11),
    IN dstatus VARCHAR (20),
    IN thunmsk YEAR (4)
	)
BEGIN
	INSERT INTO tb_siswa (nis,nama_siswa,jekel,id_kelas,status,th_masuk) VALUES 
    (dnis,dnama,djk,idk,dstatus,thunmsk);
END //
DELIMITER ;

-- UPDATE DATA SISWA --
DELIMITER //
CREATE PROCEDURE updatesiswa (
    IN dnama VARCHAR (50),
    IN djk VARCHAR (10),
    IN idk INT (11),
    IN thunmsk YEAR (4),
	IN dstatus VARCHAR (20),
    IN dnis VARCHAR (20)
	)
BEGIN
	UPDATE tb_siswa SET nama_siswa=dnama, jekel=djk, id_kelas=idk,
	status = dstatus, th_masuk=thunmsk WHERE dnis=nis;
   
END //
DELIMITER ;

-- HAPUS DATA SISWA --
DELIMITER //
CREATE PROCEDURE hapus_datasiswa(IN id INT)
BEGIN
    DELETE FROM  tb_siswa WHERE nis = id;
END //
DELIMITER ;

drop procedure hapus_datasiswa;

-- ADD KELAS --
DELIMITER //
CREATE PROCEDURE addkelas (
	IN nkelas VARCHAR (20)
	)
BEGIN
	INSERT INTO tb_kelas (kelas) VALUES 
    (nkelas);
END //
DELIMITER ;

-- Hapus Kelas --
DELIMITER //
CREATE PROCEDURE hapus_kelas(IN id INT)
BEGIN
    DELETE FROM  tb_kelas WHERE id_kelas = id;
END //
DELIMITER ;


-- SALDO TABUNGAN SISWA TIDAK BOLEH 0 --
DELIMITER //
CREATE TRIGGER saldotidakboleh_0
BEFORE INSERT ON tb_tabungan
FOR EACH ROW
BEGIN
    -- Mendapatkan saldo terkini
    DECLARE saldo_terkini DECIMAL(10,2);
    SET saldo_terkini = (SELECT SUM(setor) - SUM(tarik) FROM tb_tabungan WHERE nis = NEW.nis);
    
    -- Periksa apakah saldo terkini kurang dari atau sama dengan 0
    IF saldo_terkini - NEW.tarik <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo dalam tabungan tidak boleh menjadi 0 setelah melakukan penarikan.';
    END IF;
END //
DELIMITER ;

drop trigger check_saldo_trigger;


-- NIM YANG DI IMPUTKAN HARUS SESUAI --
DELIMITER //
CREATE TRIGGER panjang_nim BEFORE INSERT ON tb_siswa
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.nis) < 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NIM harus terdiri dari 12 angka';
    END IF;
END // 





