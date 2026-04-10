import 'package:flutter/material.dart';
import 'api_config.dart';
import 'pages/halaman_login.dart'; // Import halaman pertama

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.muatIpTersimpan();

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
        fontFamily: 'Roboto', 
      ),
      // Aplikasi dimulai dari Halaman Login
      home: const HalamanLogin(), 
      debugShowCheckedModeBanner: false,
    );
  }
}