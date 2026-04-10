import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Ini IP bawaan (fallback) kalau belum pernah di-setting
  static String _ipAddress = '192.168.1.10'; 
  
  // Sesuaikan dengan nama folder project CodeIgniter kamu di htdocs
  static const String _folderName = 'imsv2'; 

  // URL lengkap yang akan dibaca oleh semua halaman
  static String get baseUrl => 'http://$_ipAddress/$_folderName/index.php/api';

  // Fungsi untuk mengambil IP yang tersimpan di HP saat aplikasi baru dibuka
  static Future<void> muatIpTersimpan() async {
    final prefs = await SharedPreferences.getInstance();
    // Kalau ada IP yang tersimpan, gunakan itu. Kalau tidak, pakai default.
    _ipAddress = prefs.getString('saved_ip') ?? _ipAddress;
  }

  // Fungsi untuk menyimpan IP baru dari halaman Login
  static Future<void> simpanIpBaru(String ipBaru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_ip', ipBaru);
    _ipAddress = ipBaru; // Langsung update variabel saat itu juga
  }

  // Untuk menampilkan IP saat ini di kolom input text
  static String get ipSaatIni => _ipAddress;
}