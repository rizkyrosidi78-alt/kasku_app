import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  // Dibuat opsional agar tidak error saat dipanggil dari MainNavigation
  final List<Map<String, dynamic>>? transaksi;
  const HomePage({super.key, this.transaksi});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _namaDepan = "User..."; 
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _ambilNamaDepan(); 
  }

  Future<void> _ambilNamaDepan() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          String fullName = userDoc['name'] ?? 'User';
          if (mounted) {
            setState(() {
              _namaDepan = fullName.split(' ').first; 
            });
          }
        }
      } catch (e) {
        if (mounted) setState(() => _namaDepan = "User");
      }
    }
  }

  String _formatRupiah(dynamic angka) {
    int parsed = 0;
    if (angka is int) {
      parsed = angka;
    } else if (angka is double) {
      parsed = angka.toInt();
    } else if (angka is String) {
      parsed = int.tryParse(angka.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return NumberFormat.decimalPattern('id').format(parsed);
  }

  String _getCurrentMonthYear() {
    final DateTime now = DateTime.now();
    const List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: currentUser == null 
            ? Center(child: Text("Silakan login terlebih dahulu", style: GoogleFonts.poppins()))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('transactions')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Terjadi kesalahan sistem", style: GoogleFonts.poppins()));
                  }

                  // --- KALKULASI SALDO OTOMATIS DARI FIREBASE ---
                  double totalPemasukan = 0;
                  double totalPengeluaran = 0;
                  
                  List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

                  for (var doc in docs) {
                    Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                    // Membaca nominal dengan aman dari database
                    double nominal = 0;
                    if (item['nominal'] is int) {
                      nominal = (item['nominal'] as int).toDouble();
                    } else if (item['nominal'] is String) {
                      nominal = double.tryParse(item['nominal'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    }

                    if (item['tipe'] == 'pemasukan') {
                      totalPemasukan += nominal;
                    } else {
                      totalPengeluaran += nominal;
                    }
                  }
                  
                  double totalSaldo = totalPemasukan - totalPengeluaran;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- NAVBAR ATAS ---
                        Container(
                          width: double.infinity,
                          height: 41,
                          color: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.only(left: 20, top: 5),
                          child: Image.asset('assets/logo_kasku.png', width: 103, height: 26, alignment: Alignment.centerLeft),
                          
                        ),
                        const SizedBox(height: 20),

                        // --- GREETING TEKS ---
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hi, $_namaDepan!", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF000000))),
                              Text("Apa kabarmu hari ini ?", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF000000))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- RECTANGLE SALDO ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Container(
                            width: double.infinity,
                            height: 184,
                            decoration: BoxDecoration(color: const Color(0xFF112D4E), borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.only(left: 27, top: 17, right: 27),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Current Balance", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF))),
                                Text(
                                  "Rp ${_formatRupiah(totalSaldo)}", 
                                  style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                const Spacer(),
                                Text(_getCurrentMonthYear(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF))),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("+Pemasukan", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF4FFBDF))),
                                        Text(
                                          "Rp +${_formatRupiah(totalPemasukan)}", 
                                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4FFBDF)),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("-Pengeluaran", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444))),
                                        Text(
                                          "Rp -${_formatRupiah(totalPengeluaran)}", 
                                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- TRANSAKSI TERBARU ---
                        Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Text("Transaksi Terbaru", style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF000000))),
                        ),
                        const SizedBox(height: 10),

                        // --- DAFTAR TRANSAKSI ---
                        if (docs.isEmpty) 
                           Center(
                             child: Padding(
                               padding: const EdgeInsets.only(top: 20),
                               child: Text("Belum ada transaksi tersimpan.", style: GoogleFonts.poppins(color: Colors.grey)),
                             )
                           )
                        else
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final item = docs[index].data() as Map<String, dynamic>;
                              bool isIncome = item['tipe'] == 'pemasukan';
                              
                              String formattedNominal = "${isIncome ? '+' : '-'}${_formatRupiah(item['nominal'])}";
                              Color iconBgColor = isIncome ? const Color(0xFF4FFBDF) : const Color(0xFFEF4444);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                width: double.infinity,
                                height: 63,
                                decoration: BoxDecoration(color: const Color(0xFFDBE2EF), borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 21),
                                    Container(
                                      width: 33, height: 36,
                                      decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8.5)),
                                      padding: const EdgeInsets.all(0),
                                      child: Image.asset(
                                        item['iconPath'] ?? 'assets/logo_kasku.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image, color: Colors.white, size: 16);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['kategori'] ?? 'Kategori', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF000000))),
                                          Text(
                                            (item['note'] ?? '').toString().length > 40 ? '${item['note'].toString().substring(0, 40)}...' : (item['note'] ?? ''),
                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Rp $formattedNominal",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16, fontWeight: FontWeight.w700, 
                                              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)
                                            ),
                                          ),
                                          Text(item['tanggal_string'] ?? '', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF000000))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}