import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112D4E),
        title: Text(
          "Home Page",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF9F7F7),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Berhasil Login!\n(Halaman Utama Masih Kosong)",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF112D4E),
          ),
        ),
      ),
    );
  }
}