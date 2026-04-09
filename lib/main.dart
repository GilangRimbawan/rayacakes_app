import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

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
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Font standar yang bersih
      ),
      home: const HalamanLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 1. HALAMAN LOGIN
// ==========================================
class HalamanLogin extends StatefulWidget {
  const HalamanLogin({Key? key}) : super(key: key);

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanDashboard()),
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
      backgroundColor: warnaBackground,
      body: Center(
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
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
    );
  }
}

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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Laporan belum dibuat')));
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