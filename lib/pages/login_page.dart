import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import ini wajib

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variabel untuk loading agar user tahu proses sedang berjalan
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Fungsi Login Firebase
  Future<void> _prosesLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menghubungkan ke Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika berhasil, pindah ke Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Jika gagal, tampilkan pesan error dari Firebase
      String errorMessage = e.message ?? "Terjadi kesalahan saat login";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo
              // Pastikan path asset ini benar sesuai di pubspec.yaml
              Image.asset(
                'assets/logo_kasku.png',
                width: 182,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 70),

              // Form Login
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF112D4E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 55,
                        alignment: Alignment.center,
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF9F7F7),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration("Masukkan email"),
                            ),
                            const SizedBox(height: 15),
                            Text("Password", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: _inputDecoration("Masukkan password"),
                            ),
                            const SizedBox(height: 25),
                            
                            // Tombol Masuk
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _prosesLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF112D4E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text("Masuk", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              // Register Link
              RichText(
                text: TextSpan(
                  text: "Belum punya akun? ",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Register",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF112D4E),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/register');
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

  // Dekorasi Input agar rapi
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFDBE2EF)),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFDBE2EF), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF112D4E), width: 2)),
    );
  }
}