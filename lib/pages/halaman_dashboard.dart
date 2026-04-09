import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

// Import semua halaman agar tombol menunya bisa jalan
import 'halaman_login.dart';
import 'halaman_inventaris.dart';
import 'halaman_tambah_produksi.dart';
import 'halaman_laporan.dart';

// ==========================================
// 2. HALAMAN DASHBOARD (FULL API)
// ==========================================
class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({Key? key}) : super(key: key);

  @override
  _HalamanDashboardState createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  String _totalProduksiHariIni = '0';
  bool _isLoadingTotal = true;

  @override
  void initState() {
    super.initState();
    _ambilTotalProduksi(); // Tarik data saat masuk dashboard
  }

Future<void> _ambilTotalProduksi() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/total_hari_ini');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _totalProduksiHariIni = data['total'].toString();
          });
        }
      } else {
        print('Error Server: ${response.statusCode}');
      }
    } catch (e) {
      print('Gagal mengambil total produksi: $e');
    } finally {
      // INI KUNCINYA: Apapun yang terjadi (sukses ataupun error),
      // animasi loading WAJIB dimatikan.
      setState(() { 
        _isLoadingTotal = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      body: SafeArea(
        child: Padding(
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: warnaPrimary.withOpacity(0.2),
                    child: Icon(Icons.person, size: 32, color: warnaPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- KARTU RINGKASAN PRODUKSI ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [warnaPrimary, const Color(0xFFFFB380)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [BoxShadow(color: warnaPrimary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Produksi', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _isLoadingTotal 
                        ? const CircularProgressIndicator(color: Colors.white) // Animasi loading mini
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _totalProduksiHariIni, // Menggunakan variabel dinamis dari API
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Text('Kue', style: TextStyle(fontSize: 18, color: Colors.white70)),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- GRID MENU ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      context: context, judul: 'Inventaris', ikon: Icons.inventory_2_outlined, warnaIkon: Colors.blue,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanInventaris()));
                      },
                    ),
                    _buildMenuCard(
                      context: context, judul: 'Produksi', ikon: Icons.cake_outlined, warnaIkon: warnaPrimary,
                      onTap: () async {
                        // Gunakan await agar saat kembali dari halaman tambah produksi, dashboard me-refresh angkanya
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanTambahProduksi()));
                        _ambilTotalProduksi(); // Refresh data
                      },
                    ),
                    _buildMenuCard(
                      context: context, judul: 'Laporan', ikon: Icons.bar_chart_rounded, warnaIkon: Colors.purple,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
        },
                    ),
                    _buildMenuCard(
                      context: context, judul: 'Keluar', ikon: Icons.logout_rounded, warnaIkon: Colors.redAccent,
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLogin()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required BuildContext context, required String judul, required IconData ikon, required Color warnaIkon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: warnaIkon.withOpacity(0.1), shape: BoxShape.circle),
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