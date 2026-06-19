

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar agar responsif di berbagai perangkat
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jarak dari atas layar (mensimulasikan posisi Y=100)
              const SizedBox(height: 50),

              // 1. Logo & Teks "Kasku" (W=182, H=42)
              Image.asset(
                'assets/logo_kasku.png',
                width: 182,
                height: 42,
                fit: BoxFit.contain,
              ),

              // Jarak antara logo dan gambar uang
              const SizedBox(height: 30),

              // 2. Gambar Uang (Posisi tersimulasi X=-60, W=513, H=447)
              // Menggunakan OverflowBox karena lebar gambar melebihi lebar layar iPhone 16 (393)
              SizedBox(
                height: 380, // Disesuaikan sedikit agar muat dengan proporsi layar
                width: size.width,
                child: OverflowBox(
                  maxWidth: 513,
                  maxHeight: 447,
                  child: Image.asset(
                    'assets/money.png',
                    width: 513,
                    height: 447,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Jarak dari gambar ke judul
              const SizedBox(height: 20),

              // 3. Judul "Catat Pengeluaran dengan Mudah"
              SizedBox(
                width: 250, // Mendekati dimensi W=234 yang kamu minta
                child: Text(
                  "Catat Pengeluaran\ndengan Mudah",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: Colors.black87,
                    height: 1.3, // Jarak antar baris teks
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 4. Teks Deskripsi
              SizedBox(
                width: 280, // Mendekati dimensi W=271
                child: Text(
                  "Catat setiap pengeluaran harianmu\nkapan saja dan dimana saja.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500, // Medium
                    color: Colors.black54, // Abu-abu agar lebih elegan
                  ),
                ),
              ),

              // Spacer akan mendorong elemen di bawahnya (tombol) hingga ke dasar layar
              const Spacer(),

              // 5. Tombol "MULAI" (Posisi Y=793)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: 317,
                  // Catatan: Di desain H=33, namun standar tombol HP minimum adalah 48 agar mudah dipencet.
                  // Aku atur ke 50 agar terlihat persis seperti di gambar. Kamu bisa ubah ke 33 jika mau.
                  height: 50, 
                  child: ElevatedButton(
                    onPressed: () {
                      // Fungsi untuk lanjut ke halaman login
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF112D4E),
                      shape: RoundedRectangleBorder(
                         // Corner radius = 24
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "MULAI",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600, // SemiBold
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}