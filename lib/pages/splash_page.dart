import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Mengatur timer selama 3 detik sebelum pindah ke halaman Onboarding
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang sesuai permintaanmu (Hex: F9F7F7)
      backgroundColor: const Color(0xFFF9F7F7),
      body: Center(
        // Menampilkan logo di tengah layar
        child: Image.asset(
          'assets/logo.png',
          width: 150, // Kamu bisa menyesuaikan ukuran lebar logo di sini
          height: 150, // Kamu bisa menyesuaikan ukuran tinggi logo di sini
        ),
      ),
    );
  }
}