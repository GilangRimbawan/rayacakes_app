import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart'; // Memanggil file konfigurasi API kita

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raya Cakes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Kita ubah halaman awalnya menjadi HalamanLogin
      home: const HalamanLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. HALAMAN LOGIN
class HalamanLogin extends StatefulWidget {
  const HalamanLogin({Key? key}) : super(key: key);

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Warna kustom berdasarkan desain gambar
  final Color warnaBackground = const Color(0xFFFFF5E9); // Peach sangat muda
  final Color warnaPrimary = const Color(0xFFFF944D); // Orange pastel untuk tombol/ikon
  final Color warnaTeksUtama = const Color(0xFF4A3F35); // Cokelat gelap untuk teks

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanTambahProduksi()),
          );
        } else {
          _tampilkanPesan(responseData['message'] ?? 'Login gagal');
        }
      } else {
        _tampilkanPesan('Gagal terhubung ke server (Error ${response.statusCode})');
      }
    } catch (e) {
      _tampilkanPesan('Terjadi kesalahan jaringan: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground, // Warna latar peach lembut
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bagian Logo dan Judul
              Icon(Icons.cake_rounded, size: 80, color: warnaPrimary),
              const SizedBox(height: 16),
              Text(
                'Raya Cakes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: warnaTeksUtama,
                ),
              ),
              const SizedBox(height: 40),

              // Kotak Card Putih
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: warnaTeksUtama,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Username
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide.none, // Menghilangkan garis pinggir
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Login
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
                              backgroundColor: warnaPrimary,
                              foregroundColor: Colors.white, // Warna teks tombol
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 0, // Dibuat flat sesuai desain modern
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                    const SizedBox(height: 16),

                    // Teks Lupa Password
                    Center(
                      child: TextButton(
                        onPressed: () {}, // Kosong karena bukan fokus fitur
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN TAMBAH PRODUKSI (KODE ASLIMU)
// ==========================================
class HalamanTambahProduksi extends StatefulWidget {
  const HalamanTambahProduksi({Key? key}) : super(key: key);

  @override
  _HalamanTambahProduksiState createState() => _HalamanTambahProduksiState();
}

class _HalamanTambahProduksiState extends State<HalamanTambahProduksi> {
  String? _resepTerpilih; 
  final TextEditingController _jumlahController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produksi Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _resepTerpilih,
              hint: const Text('Pilih Resep...'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: '1', child: Text('Resep Nastar Klasik')),
                DropdownMenuItem(value: '2', child: Text('Resep Bolu Cokelat')),
              ],
              onChanged: (String? nilaiBaru) {
                setState(() {
                  _resepTerpilih = nilaiBaru;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                labelText: 'Jumlah Produksi',
                hintText: 'Contoh: 10',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                print('Resep ID: $_resepTerpilih');
                print('Jumlah: ${_jumlahController.text}');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Simpan Produksi'),
            ),
          ],
        ),
      ),
    );
  }
}