import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

// ==========================================
// 4. HALAMAN INVENTARIS (BARU)
// ==========================================
class HalamanInventaris extends StatefulWidget {
  const HalamanInventaris({Key? key}) : super(key: key);

  @override
  _HalamanInventarisState createState() => _HalamanInventarisState();
}

class _HalamanInventarisState extends State<HalamanInventaris> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  List<dynamic> _listBahan = [];
  List<dynamic> _listFiltered = []; // Untuk hasil pencarian
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataInventaris(); // Panggil API saat halaman dibuka
  }

  // Fungsi untuk mengambil data dari CodeIgniter
  Future<void> _ambilDataInventaris() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/bahan_baku');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listBahan = data;
          _listFiltered = data; // Awalnya tampilkan semua
          _isLoading = false;
        });
      } else {
        _tampilkanPesan('Gagal mengambil data dari server');
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      _tampilkanPesan('Kesalahan jaringan: $e');
      setState(() { _isLoading = false; });
    }
  }

  // Fungsi untuk mencari bahan
  void _cariBahan(String kataKunci) {
    setState(() {
      if (kataKunci.isEmpty) {
        _listFiltered = _listBahan;
      } else {
        _listFiltered = _listBahan.where((item) {
          // Sesuaikan 'nama_bahan' dengan nama kolom di database kamu
          final nama = item['nama_bahan']?.toString().toLowerCase() ?? '';
          return nama.contains(kataKunci.toLowerCase());
        }).toList();
      }
    });
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      appBar: AppBar(
        backgroundColor: warnaBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: warnaTeksUtama),
        title: Text('Inventaris Bahan', style: TextStyle(color: warnaTeksUtama, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // --- KOTAK PENCARIAN ---
            TextField(
              onChanged: (nilai) => _cariBahan(nilai),
              decoration: InputDecoration(
                hintText: 'Cari bahan...',
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

            // --- DAFTAR BAHAN BAKU ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _listFiltered.isEmpty
                      ? Center(child: Text('Bahan tidak ditemukan', style: TextStyle(color: Colors.grey[600])))
                      : ListView.builder(
                          itemCount: _listFiltered.length,
                          itemBuilder: (context, index) {
                            final item = _listFiltered[index];
                            
                            // Ambil data dari JSON (Sesuaikan key-nya dengan database kamu)
                            final namaBahan = item['nama_bahan'] ?? 'Nama Bahan';
                            final satuan = item['satuan'] ?? '';
                            // Asumsikan field stok berupa angka
                            final stokDouble = double.tryParse(item['stok']?.toString() ?? '0') ?? 0.0;
                            final stok = stokDouble.toInt();
                            final batasKritis = double.tryParse(item['batas_kritis']?.toString() ?? '0') ?? 0.0;
                            final isStokTipis = stokDouble <= batasKritis;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: isStokTipis ? const Color(0xFFFFF0F0) : Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border: isStokTipis ? Border.all(color: Colors.red.shade200, width: 1) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Ikon Box
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isStokTipis ? Colors.red.shade50 : warnaBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.inventory_2_outlined, color: isStokTipis ? Colors.red : warnaPrimary),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Nama Bahan
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
                                  
                                  // Jumlah Stok
                                  Text(
                                    '$stok $satuan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isStokTipis ? Colors.red : warnaTeksUtama,
                                    ),
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