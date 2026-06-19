import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasku_app/user_data.dart';

// 1. Mengubah menjadi StatefulWidget agar bisa mengelola inputan teks
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. Membuat "Penangkap Teks" untuk Email dan Password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Membersihkan memori saat halaman ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Fungsi Simulasi Login
  void _prosesLogin() {
  String email = _emailController.text;
  String password = _passwordController.text;

  // Cek apakah data cocok dengan yang disimpan di UserData
  if (email == UserData.registeredEmail && 
      password == UserData.registeredPassword && 
      email.isNotEmpty) {
    
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email atau Password salah!')),
    );
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

              Image.asset(
                'assets/logo_kasku.png',
                width: 182,
                height: 42,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 70),

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
                          color: const Color(0xFFF9F7F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 25), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _emailController, // Memasang penangkap teks email
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Masukkan email",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFDBE2EF),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F7F7),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDBE2EF),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF112D4E),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            Text(
                              "Password",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _passwordController, // Memasang penangkap teks password
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Masukkan password",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFDBE2EF),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F7F7),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDBE2EF),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF112D4E),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 48, 
                              child: ElevatedButton(
                                onPressed: _prosesLogin, // Memanggil fungsi pengecekan di atas
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF112D4E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Masuk",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF9F7F7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 61, 
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "Belum punya akun? ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFF9F7F7),
                            ),
                            children: [
                              TextSpan(
                                text: "register",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFF9F7F7),
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}