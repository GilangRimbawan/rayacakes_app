<div align="center">

<img src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/flutter/flutter.png" width="100" height="100" alt="Flutter Logo">

# Raya Cakes App - Mobile Frontend

### Aplikasi Manajemen Inventaris dan Produksi Kue Berbasis Mobile  
### (Projek Tugas Akhir / Skripsi)

<br>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Tablet-lightgrey?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

</div>

---

# Tentang Proyek

Raya Cakes App merupakan aplikasi frontend mobile berbasis Flutter yang dirancang sebagai bagian dari Sistem Informasi Inventory dan Produksi Kue untuk kebutuhan proyek skripsi.

Aplikasi ini difokuskan untuk membantu aktivitas operasional produksi di area dapur menggunakan perangkat Android maupun Tablet secara praktis dan real-time.

Sistem bekerja menggunakan arsitektur Client-Server, di mana aplikasi mobile mengambil dan mengirim data melalui REST API yang disediakan oleh backend web berbasis CodeIgniter.

## Repository Backend

Backend Web (IMS v2):  
https://github.com/GilangRimbawan/rayacakes_web.git

---

# Fitur Utama

## Autentikasi Pengguna & Remember Me

- Sistem login aman
- Penyimpanan sesi menggunakan `shared_preferences`
- Mendukung fitur Remember Me untuk mempermudah login operasional berulang

---

## Pengaturan IP Server Dinamis

Fitur untuk mengganti alamat IP API secara langsung dari aplikasi tanpa perlu hardcode ulang source code.

Fitur tambahan:
- Penyimpanan history 5 IP terakhir
- Mendukung simulasi jaringan lokal:
  - WiFi
  - Hotspot Portable
  - Demo sidang skripsi

---

## Dashboard Produksi

Menampilkan:
- Total capaian produksi harian
- Ringkasan aktivitas produksi
- Data real-time dari server

---

## Pencatatan Produksi Otomatis

Input produksi berdasarkan resep yang dipilih.

Sistem akan otomatis:
- Mengurangi stok bahan baku
- Menambahkan stok produk jadi
- Menyimpan histori produksi ke database

---

## Sistem Validasi Anti-Stok Minus

Sebelum proses produksi dijalankan, sistem akan melakukan:
- Scanning seluruh kebutuhan bahan resep
- Validasi stok gudang
- Pencegahan transaksi jika stok tidak mencukupi

Jika ada bahan yang kurang:
- Produksi otomatis diblokir
- Sistem menampilkan detail notifikasi kekurangan bahan

Tujuan:
- Menjaga integritas data inventaris
- Mencegah stok minus

---

# Getting Started

## Prasyarat

Pastikan perangkat sudah terinstall:

- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Android Device / Emulator

---

# Instalasi

## 1. Clone Repository

```bash
git clone https://github.com/GilangRimbawan/raya_cakes_app.git
````

---

## 2. Masuk ke Folder Project

```bash
cd raya_cakes_app
```

---

## 3. Install Dependencies

```bash
flutter pub get
```

---

## 4. Jalankan Aplikasi

```bash
flutter run
```

---

# Struktur Direktori

```text
lib/
├── api_config.dart
│   └── Konfigurasi Base URL, IP Dinamis, dan History IP

├── main.dart
│   └── Entry Point aplikasi & inisialisasi SharedPreferences

└── pages/
    ├── halaman_login.dart
    │   └── UI Login, Remember Me, Dialog Ganti IP

    └── halaman_dashboard.dart
        └── Dashboard Utama & Logout Aman
```

---

# Teknologi yang Digunakan

* Flutter
* Dart
* REST API
* Shared Preferences
* Material Design

---

# Developer

<div align="center">

### Projek Tugas Akhir / Skripsi

### Gilang Akhbara Rimbawan

</div>