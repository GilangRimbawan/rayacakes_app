import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

import 'halaman_login.dart';
import 'halaman_inventaris.dart';
import 'halaman_tambah_produksi.dart';
import 'halaman_laporan.dart';

class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({super.key});

  @override
  _HalamanDashboardState createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  String _totalProduksiHariIni = '0';
  bool _isLoadingTotal = true;
  
  // Variabel baru untuk fitur Peringatan Bahan Kritis
  int _jumlahBahanKritis = 0;
  bool _isLoadingBahan = true;

  DateTime? _waktuTerakhirTekanBack;

  @override
  void initState() {
    super.initState();
    _ambilTotalProduksi();
    _cekBahanKritis(); // Panggil pengecekan bahan saat dashboard dibuka
  }

  // --- FUNGSI 1: AMBIL TOTAL PRODUKSI ---
  Future<void> _ambilTotalProduksi() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/total_hari_ini');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _totalProduksiHariIni = data['total'].toString();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal mengambil total produksi: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoadingTotal = false; });
      }
    }
  }

  // --- FUNGSI 2: CEK BAHAN BAKU KRITIS (BARU) ---
  Future<void> _cekBahanKritis() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/bahan_baku');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        int jumlahKritis = 0;

        // Loop untuk mengecek satu-satu mana yang stoknya di bawah batas kritis
        for (var item in data) {
          final stok = double.tryParse(item['stok']?.toString() ?? '0') ?? 0.0;
          final batasKritis = double.tryParse(item['batas_kritis']?.toString() ?? '0') ?? 0.0;
          
          if (stok <= batasKritis) {
            jumlahKritis++;
          }
        }

        if (mounted) {
          setState(() {
            _jumlahBahanKritis = jumlahKritis;
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal cek bahan kritis: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoadingBahan = false; });
      }
    }
  }

  void _konfirmasiKeluar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLogin()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi khusus saat navigasi, agar halaman merefresh diri setelah kembali
  Future<void> _navigasiDanRefresh(Widget halaman) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => halaman));
    _ambilTotalProduksi();
    _cekBahanKritis();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        final sekarang = DateTime.now();
        final jatahWaktuKeluar = _waktuTerakhirTekanBack == null || 
            sekarang.difference(_waktuTerakhirTekanBack!) > const Duration(seconds: 2);

        if (jatahWaktuKeluar) {
          _waktuTerakhirTekanBack = sekarang;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tekan sekali lagi untuk keluar dari aplikasi'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: warnaBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, Admin!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
                        const SizedBox(height: 4),
                        Text('Siap memproduksi kue hari ini?', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'profil') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Profil belum dibuat')));
                        } else if (value == 'logout') {
                          _konfirmasiKeluar();
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      offset: const Offset(0, 50),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'profil',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, color: warnaTeksUtama),
                              const SizedBox(width: 12),
                              Text('Profil Saya', style: TextStyle(color: warnaTeksUtama)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              const Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: warnaPrimary.withValues(alpha: 0.2),
                        child: Icon(Icons.person, size: 32, color: warnaPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- ALERT PERINGATAN BAHAN KRITIS (BARU) ---
                if (!_isLoadingBahan && _jumlahBahanKritis > 0) ...[
                  GestureDetector(
                    onTap: () => _navigasiDanRefresh(const HalamanInventaris()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0), // Merah pastel lembut
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Peringatan Stok!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Ada $_jumlahBahanKritis bahan baku yang hampir habis. Sentuh untuk mengecek.', style: TextStyle(color: Colors.red[800], fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // --- KARTU RINGKASAN ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [warnaPrimary, const Color(0xFFFFB380)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [BoxShadow(color: warnaPrimary.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Produksi Hari Ini', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _isLoadingTotal 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(_totalProduksiHariIni, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(width: 8),
                                const Text('Kue', style: TextStyle(fontSize: 18, color: Colors.white70)),
                              ],
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- MENU NAVIGASI ---
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        context: context, judul: 'Inventaris', ikon: Icons.inventory_2_outlined, warnaIkon: Colors.blue,
                        onTap: () => _navigasiDanRefresh(const HalamanInventaris()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMenuCard(
                        context: context, judul: 'Produksi', ikon: Icons.cake_outlined, warnaIkon: warnaPrimary,
                        onTap: () => _navigasiDanRefresh(const HalamanTambahProduksi()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildMenuCard(
                  context: context, judul: 'Laporan Produksi Lengkap', ikon: Icons.bar_chart_rounded, warnaIkon: Colors.purple,
                  isFullWidth: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context, 
    required String judul, 
    required IconData ikon, 
    required Color warnaIkon, 
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: warnaIkon.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(ikon, size: 32, color: warnaIkon),
            ),
            const SizedBox(height: 16),
            Text(judul, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
          ],
        ),
      ),
    );
  }
}