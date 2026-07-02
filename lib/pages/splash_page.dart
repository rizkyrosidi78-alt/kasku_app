import 'package:flutter/material.dart';
import 'dart:async'; // Dibutuhkan untuk efek delay/timer

// WAJIB TAMBAH: Import Firebase dan Halaman Tujuan
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Ganti dengan onboarding_page.dart jika user belum login diarahkan ke onboarding
import 'main_navigation.dart'; // Halaman utama setelah berhasil login

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Panggil fungsi pengecekan saat aplikasi baru dibuka
  }

  // ==================== FUNGSI CEK STATUS LOGIN ====================
  Future<void> _checkLoginStatus() async {
    // 1. Berikan jeda waktu (misal 3 detik) agar animasi/logo splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));

    // 2. Cek apakah ada user yang masih login di memori Firebase
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (currentUser != null) {
        // JIKA SUDAH LOGIN: Lempar langsung ke Main Navigation (Lewati Login)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        // JIKA BELUM LOGIN: Arahkan ke halaman Login (atau Onboarding)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()), 
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7), // Sesuaikan dengan warna aplikasimu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasimu
            Image.asset(
              'assets/logo.png',
              width: 200, 
            ),
            const SizedBox(height: 20),
            // Opsional: Indikator loading memutar
            const CircularProgressIndicator(color: Color(0xFF112D4E)),
          ],
        ),
      ),
    );
  }
}