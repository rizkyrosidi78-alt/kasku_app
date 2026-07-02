import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kasku_app/firebase_options.dart';
import 'package:kasku_app/pages/main_navigation.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  // 1. Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Menyalakan Firebase sesuai platform (Android/Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Menjalankan aplikasi
  runApp(const MyApp()); // Pastikan nama MyApp sesuai dengan class aplikasi utamamu
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Keuangan',
      debugShowCheckedModeBanner: false,
      // Mengatur rute halaman aplikasi
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}