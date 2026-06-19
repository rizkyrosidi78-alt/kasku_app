import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_data.dart'; // Import file jembatan yang kita buat

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk menangkap input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi Registrasi
  void _prosesRegistrasi() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom wajib diisi!')));
      return;
    }

    // Simpan data ke "Database" sementara
    UserData.registeredName = _nameController.text;
    UserData.registeredEmail = _emailController.text;
    UserData.registeredPassword = _passwordController.text;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil!')));
    Navigator.pop(context); // Kembali ke Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Logo
              Image.asset('assets/logo_kasku.png', width: 182, height: 42),
              const SizedBox(height: 70),

              // Card Biru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF112D4E), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Header "Registrasi"
                      const SizedBox(height: 20),
                      Text("Registrasi", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFFF9F7F7))),
                      const SizedBox(height: 20),

                      // Container Putih
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFF9F7F7), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input Nama
                            _buildLabel("Nama Lengkap"),
                            _buildTextField(_nameController, "Masukkan nama lengkap"),
                            const SizedBox(height: 15),
                            // Input Email
                            _buildLabel("Email"),
                            _buildTextField(_emailController, "Masukkan email"),
                            const SizedBox(height: 15),
                            // Input Password
                            _buildLabel("Password"),
                            _buildTextField(_passwordController, "Masukkan password", isPassword: true),
                            const SizedBox(height: 25),
                            // Tombol Masuk
                            SizedBox(
                              width: double.infinity, height: 48,
                              child: ElevatedButton(
                                onPressed: _prosesRegistrasi,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF112D4E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                child: Text("Masuk", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Link Login
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: RichText(
                          text: TextSpan(
                            text: "Sudah punya akun? ",
                            style: GoogleFonts.poppins(color: Colors.white),
                            children: [
                              TextSpan(text: "login", style: const TextStyle(decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget agar kode rapi
  Widget _buildLabel(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500));
  
  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFFDBE2EF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFDBE2EF), width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFDBE2EF), width: 2)),
        ),
      ),
    );
  }
}