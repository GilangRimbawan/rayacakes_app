import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'halaman_dashboard.dart'; // Untuk navigasi setelah login

// ==========================================
// 1. HALAMAN LOGIN
// ==========================================
class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final Color warnaBackground = const Color(0xFFFFF5E9); 
  final Color warnaPrimary = const Color(0xFFFF944D); 
  final Color warnaTeksUtama = const Color(0xFF4A3F35); 

  Future<void> prosesLogin() async {
    setState(() { _isLoading = true; });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // UBAH ARAH NAVIGASI: Setelah login sukses, pergi ke Dashboard
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanDashboard()),
            );
          }
        } else {
          _tampilkanPesan(responseData['message'] ?? 'Login gagal');
        }
      } else {
        _tampilkanPesan('Gagal terhubung ke server (Error ${response.statusCode})');
      }
    } catch (e) {
      _tampilkanPesan('Terjadi kesalahan jaringan: Pastikan IP Server sudah benar.');
      debugPrint('Error detail: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }

  // --- FUNGSI BARU: POPUP GANTI IP ---
  void _tampilkanDialogGantiIp() {
    final TextEditingController ipController = TextEditingController(text: ApiConfig.ipSaatIni);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.wifi_rounded, color: warnaPrimary),
            const SizedBox(width: 8),
            const Text('Pengaturan Server'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan IP Address WiFi/Hotspot saat ini:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                hintText: 'Misal: 192.168.43.15',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.computer, color: Colors.grey),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ipController.text.isNotEmpty) {
                // Simpan IP baru
                await ApiConfig.simpanIpBaru(ipController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('IP Server berhasil diperbarui!'), 
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      body: SafeArea(
        // MENGGUNAKAN STACK AGAR TOMBOL PENGATURAN BISA MELAYANG DI POJOK
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cake_rounded, size: 80, color: warnaPrimary),
                    const SizedBox(height: 16),
                    Text('Raya Cakes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Username', filled: true, fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password', filled: true, fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () {
                                    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                                      _tampilkanPesan('Username dan Password harus diisi');
                                    } else {
                                      prosesLogin();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: warnaPrimary, foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), elevation: 0,
                                  ),
                                  child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- TOMBOL PENGATURAN IP DI POJOK KANAN ATAS ---
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                  onPressed: _tampilkanDialogGantiIp,
                  tooltip: 'Pengaturan Server',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}