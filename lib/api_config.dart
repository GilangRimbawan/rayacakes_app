import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String _ipAddress = '192.168.1.10'; 
  static const String _folderName = 'imsv2'; 
  
  // Variabel baru untuk menyimpan daftar riwayat IP
  static List<String> _historyIp = [];

  static String get baseUrl => 'http://$_ipAddress/$_folderName/index.php/api';
  static String get ipSaatIni => _ipAddress;
  
  // Getter untuk mengambil daftar riwayat
  static List<String> get historyIp => _historyIp;

  static Future<void> muatIpTersimpan() async {
    final prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString('saved_ip') ?? _ipAddress;
    
    // Muat riwayat IP saat aplikasi dibuka
    _historyIp = prefs.getStringList('history_ip') ?? [];
  }

  static Future<void> simpanIpBaru(String ipBaru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_ip', ipBaru);
    _ipAddress = ipBaru;

    // --- LOGIKA RIWAYAT IP ---
    // Jika IP sudah ada di riwayat, hapus dulu biar nanti ditaruh paling atas
    if (_historyIp.contains(ipBaru)) {
      _historyIp.remove(ipBaru);
    }
    
    // Masukkan IP baru ke urutan paling atas (index 0)
    _historyIp.insert(0, ipBaru);
    
    // Batasi riwayat maksimal 5 IP saja biar tidak kepenuhan
    if (_historyIp.length > 5) {
      _historyIp.removeLast();
    }
    
    // Simpan daftar riwayat ke memori HP
    await prefs.setStringList('history_ip', _historyIp);
  }

  // Fungsi baru untuk menghapus satu IP dari riwayat (opsional)
  static Future<void> hapusDariHistory(String ipHapus) async {
    final prefs = await SharedPreferences.getInstance();
    _historyIp.remove(ipHapus);
    await prefs.setStringList('history_ip', _historyIp);
  }
}