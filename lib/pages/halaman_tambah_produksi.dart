import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

// ==========================================
// 3. HALAMAN TAMBAH PRODUKSI (FULL API)
// ==========================================
class HalamanTambahProduksi extends StatefulWidget {
  const HalamanTambahProduksi({Key? key}) : super(key: key);

  @override
  _HalamanTambahProduksiState createState() => _HalamanTambahProduksiState();
}

class _HalamanTambahProduksiState extends State<HalamanTambahProduksi> {
  String? _resepTerpilih; 
  final TextEditingController _jumlahController = TextEditingController(text: '1');

  final Color warnaBackground = const Color(0xFFFFF5E9); 
  final Color warnaPrimary = const Color(0xFFFF944D); 
  final Color warnaTeksUtama = const Color(0xFF4A3F35); 

  // --- VARIABEL UNTUK API ---
  List<dynamic> _listResep = [];
  bool _isLoadingResep = true;
  bool _isMenyimpan = false;

  @override
  void initState() {
    super.initState();
    _ambilDataResep(); // Ambil resep dari database saat halaman dibuka
  }

  // --- FUNGSI 1: MENGAMBIL DATA RESEP ---
  Future<void> _ambilDataResep() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/resep');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listResep = data;
          _isLoadingResep = false;
        });
      } else {
        _tampilkanPesan('Gagal memuat resep dari server');
        setState(() { _isLoadingResep = false; });
      }
    } catch (e) {
      _tampilkanPesan('Kesalahan jaringan saat memuat resep');
      setState(() { _isLoadingResep = false; });
    }
  }

  // --- FUNGSI 2: MENYIMPAN PRODUKSI ---
  Future<void> _simpanProduksi() async {
    // Validasi form
    if (_resepTerpilih == null) {
      _tampilkanPesan('Silakan pilih resep kue terlebih dahulu!');
      return;
    }

    setState(() { _isMenyimpan = true; });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/tambah_produksi');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_resep': _resepTerpilih,
          // Ubah nilai teks jadi angka (integer)
          'jumlah_produksi': int.tryParse(_jumlahController.text) ?? 1,
          'catatan': 'Produksi dari Aplikasi Mobile',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Tampilkan pesan sukses warna hijau
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produksi berhasil disimpan! Stok otomatis berkurang.'), backgroundColor: Colors.green),
          );
          
          // Reset form setelah sukses
          setState(() {
            _resepTerpilih = null;
            _jumlahController.text = '1';
          });
        } else {
          _tampilkanPesan(responseData['message'] ?? 'Gagal menyimpan produksi');
        }
      } else {
        _tampilkanPesan('Error Server: ${response.statusCode}');
      }
    } catch (e) {
      _tampilkanPesan('Terjadi kesalahan jaringan: $e');
    } finally {
      setState(() { _isMenyimpan = false; });
    }
  }

  // Fungsi mengubah jumlah via tombol (+/-)
  void _ubahJumlah(int nilaiTambahan) {
    int nilaiSekarang = int.tryParse(_jumlahController.text) ?? 0;
    int nilaiBaru = nilaiSekarang + nilaiTambahan;
    if (nilaiBaru < 1) nilaiBaru = 1;
    setState(() {
      _jumlahController.text = nilaiBaru.toString();
    });
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaBackground,
      appBar: AppBar(
        backgroundColor: warnaBackground,
        elevation: 0, 
        iconTheme: IconThemeData(color: warnaTeksUtama),
        title: Text('Tambah Produksi', style: TextStyle(color: warnaTeksUtama, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pilih Resep Kue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
            const SizedBox(height: 8),
            
            // --- DROPDOWN RESEP DINAMIS ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: _isLoadingResep 
                  // Tampilkan animasi muter kalau resep masih di-download dari server
                  ? const Padding(padding: EdgeInsets.all(12.0), child: Center(child: CircularProgressIndicator()))
                  : DropdownButtonFormField<String>(
                      value: _resepTerpilih,
                      hint: Text('Pilih resep...', style: TextStyle(color: Colors.grey[400])),
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: warnaPrimary),
                      decoration: const InputDecoration(border: InputBorder.none),
                      // Loop data dari database untuk dijadikan item dropdown
                      items: _listResep.map<DropdownMenuItem<String>>((item) {
                        // CATATAN: Pastikan nama kunci ini sesuai dengan tabel 'resep' di database-mu
                        final id = item['id_resep']?.toString() ?? '';
                        final nama = item['nama_resep'] ?? 'Resep Tidak Dikenal';
                        
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: (String? nilaiBaru) {
                        setState(() { _resepTerpilih = nilaiBaru; });
                      },
                    ),
            ),
            
            const SizedBox(height: 24),
            Text('Jumlah Produksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaTeksUtama)),
            const SizedBox(height: 8),
            
            // --- INPUT JUMLAH ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  IconButton(onPressed: () => _ubahJumlah(-1), icon: const Icon(Icons.remove_circle_outline), color: warnaPrimary, iconSize: 32),
                  Expanded(
                    child: TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: warnaTeksUtama),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  IconButton(onPressed: () => _ubahJumlah(1), icon: const Icon(Icons.add_circle_outline), color: warnaPrimary, iconSize: 32),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- TOMBOL SIMPAN ---
            _isMenyimpan 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _simpanProduksi, // Panggil fungsi API
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warnaPrimary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), elevation: 0,
                    ),
                    child: const Text('Simpan Produksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}