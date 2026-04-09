import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

// ==========================================
// 5. HALAMAN LAPORAN (BARU)
// ==========================================
class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({Key? key}) : super(key: key);

  @override
  _HalamanLaporanState createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  final Color warnaBackground = const Color(0xFFFFF5E9);
  final Color warnaPrimary = const Color(0xFFFF944D);
  final Color warnaTeksUtama = const Color(0xFF4A3F35);

  List<dynamic> _listLaporan = [];
  bool _isLoading = true;

  // Variabel untuk menyimpan filter tanggal
  DateTime? _tanggalAwal;
  DateTime? _tanggalAkhir;

  @override
  void initState() {
    super.initState();
    _ambilDataLaporan(); // Ambil semua data saat pertama kali dibuka
  }

  Future<void> _ambilDataLaporan() async {
    setState(() { _isLoading = true; });

    try {
      // Siapkan URL dasar
      String urlString = '${ApiConfig.baseUrl}/laporan_produksi';
      
      // Jika user memilih filter tanggal, tambahkan ke URL
      if (_tanggalAwal != null && _tanggalAkhir != null) {
        String tglAwalStr = "${_tanggalAwal!.year}-${_tanggalAwal!.month.toString().padLeft(2, '0')}-${_tanggalAwal!.day.toString().padLeft(2, '0')}";
        String tglAkhirStr = "${_tanggalAkhir!.year}-${_tanggalAkhir!.month.toString().padLeft(2, '0')}-${_tanggalAkhir!.day.toString().padLeft(2, '0')}";
        urlString += '?tgl_awal=$tglAwalStr&tgl_akhir=$tglAkhirStr';
      }

      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        setState(() {
          _listLaporan = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _tampilkanPesan('Gagal mengambil data laporan');
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      _tampilkanPesan('Kesalahan jaringan: $e');
      setState(() { _isLoading = false; });
    }
  }

  // Fungsi memunculkan kalender untuk memilih tanggal
  Future<void> _pilihTanggal(BuildContext context, bool isAwal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: warnaPrimary, 
              onPrimary: Colors.white, 
              onSurface: warnaTeksUtama,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isAwal) {
          _tanggalAwal = picked;
        } else {
          _tanggalAkhir = picked;
        }
      });
    }
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Bantuan untuk memformat tampilan teks tanggal
  String _formatTanggalTampil(DateTime? tgl) {
    if (tgl == null) return 'Pilih Tanggal';
    return "${tgl.day}/${tgl.month}/${tgl.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      appBar: AppBar(
        backgroundColor: warnaBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: warnaTeksUtama),
        title: Text('Laporan Produksi', style: TextStyle(color: warnaTeksUtama, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // --- KOTAK FILTER TANGGAL ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pilihTanggal(context, true),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(_formatTanggalTampil(_tanggalAwal), style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(foregroundColor: warnaTeksUtama),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('s/d', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pilihTanggal(context, false),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(_formatTanggalTampil(_tanggalAkhir), style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(foregroundColor: warnaTeksUtama),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_tanggalAwal != null && _tanggalAkhir != null) {
                          _ambilDataLaporan();
                        } else {
                          _tampilkanPesan('Pilih tanggal awal dan akhir terlebih dahulu');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: warnaPrimary, foregroundColor: Colors.white),
                      child: const Text('Filter Laporan'),
                    ),
                  ),
                  // Tombol Reset Filter
                  if (_tanggalAwal != null || _tanggalAkhir != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tanggalAwal = null;
                          _tanggalAkhir = null;
                        });
                        _ambilDataLaporan(); // Panggil ulang semua data
                      },
                      child: const Text('Reset Filter', style: TextStyle(color: Colors.redAccent)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- DAFTAR HASIL PRODUKSI ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _listLaporan.isEmpty
                      ? Center(child: Text('Tidak ada data produksi', style: TextStyle(color: Colors.grey[600])))
                      : ListView.builder(
                          itemCount: _listLaporan.length,
                          itemBuilder: (context, index) {
                            final item = _listLaporan[index];
                            
                            // Sesuaikan dengan nama kolom di database
                            final namaResep = item['nama_resep'] ?? 'Produk Tidak Dikenal'; 
                            final jumlah = item['jumlah_produksi']?.toString() ?? '0'; 
                            final tanggal = item['tanggal_produksi'] ?? '-'; 
                            final catatan = item['catatan'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        namaResep,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaTeksUtama),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(color: warnaPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Text('+ $jumlah', style: TextStyle(fontWeight: FontWeight.bold, color: warnaPrimary)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(tanggal, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                  if (catatan.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Catatan: $catatan', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic)),
                                  ]
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