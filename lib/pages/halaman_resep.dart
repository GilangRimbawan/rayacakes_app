import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'halaman_detail_resep.dart';

class HalamanResep extends StatefulWidget {
  const HalamanResep({super.key});

  @override
  State<HalamanResep> createState() => _HalamanResepState();
}

class _HalamanResepState extends State<HalamanResep> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  List<dynamic> _listResep = [];
  List<dynamic> _listFiltered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataResep();
  }

  Future<void> _ambilDataResep() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/resep');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listResep = data;
          _listFiltered = data;
          _isLoading = false;
        });
      } else {
        _tampilkanPesan('Gagal memuat resep dari server');
      }
    } catch (e) {
      debugPrint('Kesalahan jaringan: $e');
      _tampilkanPesan('Kesalahan jaringan saat memuat resep');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cariResep(String kataKunci) {
    setState(() {
      if (kataKunci.isEmpty) {
        _listFiltered = _listResep;
      } else {
        _listFiltered = _listResep.where((item) {
          final namaResep = item['nama_resep']?.toString().toLowerCase() ?? '';
          final namaProduk = item['nama_produk']?.toString().toLowerCase() ?? '';
          return namaResep.contains(kataKunci.toLowerCase()) ||
              namaProduk.contains(kataKunci.toLowerCase());
        }).toList();
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
          'Resep Kue',
          style: TextStyle(color: warnaTeksUtama, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              onChanged: (nilai) => _cariResep(nilai),
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _ambilDataResep,
                color: warnaPrimary,
                backgroundColor: Colors.white,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _listFiltered.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.3,
                              ),
                              Center(
                                child: Text(
                                  'Resep tidak ditemukan',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _listFiltered.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = _listFiltered[index];
                              final namaResep = item['nama_resep'] ?? 'Resep Kue';
                              final namaProduk = item['nama_produk'] ?? '';
                              final idResep = item['id_resep']?.toString() ?? '';

                              // Gunakan beberapa warna pastel secara bergantian untuk ikon
                              final warnaIkonPilihan = [
                                Colors.teal,
                                Colors.pink,
                                Colors.orange,
                                Colors.purple
                              ];
                              final warnaIkon =
                                  warnaIkonPilihan[index % warnaIkonPilihan.length];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20.0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HalamanDetailResep(
                                            idResep: idResep,
                                            namaResep: namaResep,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: warnaIkon.withValues(
                                                alpha: 0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.menu_book_rounded,
                                              color: warnaIkon,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  namaResep,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: warnaTeksUtama,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Produk: $namaProduk',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey[400],
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
