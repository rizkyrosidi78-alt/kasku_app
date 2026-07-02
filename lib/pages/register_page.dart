import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Registrasi dengan Firebase
  Future<void> _prosesRegistrasi() async {
    // 1. Cek apakah ada kolom yang kosong
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Mendaftarkan Email & Password ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Menyimpan Nama Lengkap ke Firestore Database
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': DateTime.now(),
      });

      // 4. Jika sukses, kembali ke halaman login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')));
        Navigator.pop(context); 
      }
    } on FirebaseAuthException catch (e) {
      // Menangkap error dari Firebase (misal: email sudah terdaftar, password terlalu lemah)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Terjadi kesalahan pada Firebase')));
      }
    } catch (e) {
      // Menangkap error lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      // Matikan loading animasi apa pun yang terjadi (sukses/gagal)
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/logo_kasku.png', width: 182, height: 42),
              const SizedBox(height: 70),
              
              // ==================== KOTAK BIRU GELAP (HEADER) ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF112D4E), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const SizedBox(height: 11),
                      Text("Registrasi", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFFF9F7F7))),
                      const SizedBox(height: 11),

                      // ==================== FORM PUTIH (KONTEN) ====================
                      Container(
                        margin: const EdgeInsets.all(0), // Margin dihapus agar menempel pas
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF), 
                          // KUNCI PERBAIKAN: Melingkarkan semua sudut agar tidak bocor warna biru di bawah
                          borderRadius: BorderRadius.circular(16), 
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            _buildLabel("Nama Lengkap"),
                            const SizedBox(height: 13),
                            _buildTextField(_nameController, "Masukkan nama lengkap"),
                            const SizedBox(height: 15),
                            _buildLabel("Email"),
                            const SizedBox(height: 13),
                            _buildTextField(_emailController, "Masukkan email"),
                            const SizedBox(height: 15),
                            _buildLabel("Password"),
                            const SizedBox(height: 13),
                            _buildTextField(_passwordController, "Masukkan password", isPassword: true),
                            const SizedBox(height: 25),
                            
                            // Tombol Daftar
                            SizedBox(
                              width: double.infinity, height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _prosesRegistrasi,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF112D4E), 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
                                ),
                                child: _isLoading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text("Daftar", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25), // Jarak ke teks login

              // ==================== TEKS LOGIN (DI LUAR KOTAK BIRU) ====================
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RichText(
                  text: TextSpan(
                    text: "Sudah punya akun? ",
                    style: GoogleFonts.poppins(color: const Color(0xFF000000), fontSize: 14), // Teks warna hitam
                    children: [
                      TextSpan(
                        text: "login", 
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFF112D4E), // Warna biru untuk link
                          fontWeight: FontWeight.w600,
                        ), 
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context)
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