import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class HalamanDetailResep extends StatefulWidget {
  final String idResep;
  final String namaResep;

  const HalamanDetailResep({
    super.key,
    required this.idResep,
    required this.namaResep,
  });

  @override
  State<HalamanDetailResep> createState() => _HalamanDetailResepState();
}

class _HalamanDetailResepState extends State<HalamanDetailResep> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  List<dynamic> _detailResep = [];
  bool _isLoading = true;
  int _kelipatanBatch = 1; // Fitur premium: pengali batch produksi

  @override
  void initState() {
    super.initState();
    _ambilDetailResep();
  }

  Future<void> _ambilDetailResep() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/resep_detail/${widget.idResep}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _detailResep = data;
          _isLoading = false;
        });
      } else {
        _tampilkanPesan('Gagal memuat detail resep dari server');
      }
    } catch (e) {
      debugPrint('Kesalahan jaringan: $e');
      _tampilkanPesan('Kesalahan jaringan saat memuat detail resep');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _ubahKelipatan(int delta) {
    setState(() {
      _kelipatanBatch += delta;
      if (_kelipatanBatch < 1) {
        _kelipatanBatch = 1;
      }
    });
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      appBar: AppBar(
        backgroundColor: warnaBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: warnaTeksUtama),
        title: Text(
          widget.namaResep,
          style: TextStyle(color: warnaTeksUtama, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detailResep.isEmpty
              ? Center(
                  child: Text(
                    'Detail resep tidak ditemukan atau kosong',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- KARTU INFORMASI UTAMA & FITUR BATCH ---
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [warnaPrimary, const Color(0xFFFFB380)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: warnaPrimary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Kalkulator Bahan Produksi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Sesuaikan jumlah batch untuk melipatgandakan kebutuhan takaran bahan secara otomatis:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _ubahKelipatan(-1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    iconSize: 28,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '$_kelipatanBatch Batch',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _ubahKelipatan(1),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    iconSize: 28,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- HEADER DAFTAR BAHAN ---
                      Text(
                        'Kebutuhan Bahan Baku',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: warnaTeksUtama,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- DAFTAR BAHAN BAKU ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _detailResep.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: Color(0xFFF0F0F0),
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, index) {
                            final item = _detailResep[index];
                            final namaBahan =
                                item['nama_bahan'] ?? 'Bahan Tidak Dikenal';
                            final satuan = item['satuan'] ?? '';
                            final jumlahSatuBatch =
                                double.tryParse(item['jumlah']?.toString() ?? '0') ??
                                    0.0;
                            final jumlahTotal =
                                jumlahSatuBatch * _kelipatanBatch;

                            // Hilangkan desimal .00 jika angkanya bulat
                            final jumlahFormatted = jumlahTotal % 1 == 0
                                ? jumlahTotal.toInt().toString()
                                : jumlahTotal.toStringAsFixed(2);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      color: warnaPrimary,
                                      size: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      namaBahan,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: warnaTeksUtama,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$jumlahFormatted $satuan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: warnaPrimary,
                                        ),
                                      ),
                                      if (_kelipatanBatch > 1)
                                        Text(
                                          '(${jumlahSatuBatch % 1 == 0 ? jumlahSatuBatch.toInt().toString() : jumlahSatuBatch.toStringAsFixed(2)} $satuan / batch)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
