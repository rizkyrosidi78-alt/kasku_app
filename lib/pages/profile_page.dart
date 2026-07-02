import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileAvatarPath; // Menyimpan teks alamat asset (misal: assets/avatar1.png)
  String namaLengkap = "Memuat data...";
  String emailUser = "Memuat data...";
  
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Daftar Avatar yang tersedia (Bisa kamu tambah lagi nanti di sini)
  final List<String> _daftarAvatar = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
  ];

  @override
  void initState() {
    super.initState();
    _ambilDataUser();
  }

  // ==================== FUNGSI AMBIL DATA USER ====================
  Future<void> _ambilDataUser() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          if (mounted) {
            setState(() {
              namaLengkap = data?['name'] ?? 'Nama tidak ada';
              emailUser = data?['email'] ?? currentUser!.email ?? 'Email tidak ada';
              // Mengambil path avatar dari field 'profileUrl' (biar tidak perlu ganti nama field)
              _profileAvatarPath = data?['profileUrl'];
            });
          }
        }
      } catch (e) {
        if (mounted) setState(() => namaLengkap = "Gagal memuat data");
      }
    }
  }

  // ==================== FUNGSI UPDATE AVATAR KE FIREBASE ====================
  Future<void> _updateAvatar(String path) async {
    try {
      if (currentUser != null) {
        // Simpan teks path asset ke Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({'profileUrl': path});

        setState(() {
          _profileAvatarPath = path;
        });

        if (mounted) {
          Navigator.pop(context); // Tutup menu pilihan avatar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar berhasil diubah!'), backgroundColor: Color(0xFF112D4E)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah avatar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== POP UP PILIHAN AVATAR (BOTTOM SHEET) ====================
  void _tampilkanPilihanAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF9F7F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("Pilih Avatar Keren", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF112D4E))),
              const SizedBox(height: 20),
              
              // Grid tampilan avatar
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 kotak ke samping
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                itemCount: _daftarAvatar.length,
                itemBuilder: (context, index) {
                  String path = _daftarAvatar[index];
                  return GestureDetector(
                    onTap: () => _updateAvatar(path),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _profileAvatarPath == path ? const Color(0xFF112D4E) : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(path, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // ==================== FUNGSI LOGOUT ====================
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, 
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // ==================== BAGIAN FOTO PROFIL ====================
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 93,
                        height: 93,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF112D4E), width: 2), 
                        ),
                        child: ClipOval(
                          child: (_profileAvatarPath != null && _profileAvatarPath!.startsWith('assets/'))
                              ? Image.asset(
                                  _profileAvatarPath!,
                                  fit: BoxFit.cover,
                                  width: 93,
                                  height: 93,
                                )
                              : const Icon(Icons.person, size: 50, color: Color(0xFF112D4E)),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _tampilkanPilihanAvatar,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFF112D4E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _buildInfoCard(icon: Icons.person, label: "Nama Lengkap", value: namaLengkap),
              const SizedBox(height: 12),
              _buildInfoCard(icon: Icons.email, label: "Email", value: emailUser),

              const Spacer(),

              SizedBox(
                width: 325,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: _logout, 
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFDBE2EF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      width: double.infinity,
      height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE2EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF112D4E), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF000000))),
                Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF112D4E)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}