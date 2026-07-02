import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- TAMBAHAN IMPORT FIREBASE ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticPage extends StatefulWidget {
  // Dibuat opsional agar tidak error saat dipanggil dari MainNavigation
  final List<Map<String, dynamic>>? transaksi;

  const StatisticPage({super.key, this.transaksi});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper untuk memformat angka ke format Rupiah
  String _formatRupiah(dynamic nominal) {
    int value = 0;
    if (nominal is int) {
      value = nominal;
    } else if (nominal is double) {
      value = nominal.toInt();
    } else if (nominal is String) {
      value = int.tryParse(nominal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    String str = value.toString();
    String result = '';
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i != 0) {
        result = '.$result';
        count = 0;
      }
    }
    return result;
  }

  // Bonus: Fungsi untuk mengambil bulan dan tahun saat ini secara otomatis
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
    // 3. Daftar kategori pengeluaran statis beserta warnanya sesuai spesifikasi
    final List<Map<String, dynamic>> daftarKategori = [
      {'nama': 'Makan', 'warna': const Color(0xFFFFAD2A)},
      {'nama': 'Belanja', 'warna': const Color(0xFF77E68A)},
      {'nama': 'Transportasi', 'warna': const Color(0xFF3CBEFC)},
      {'nama': 'Rumah', 'warna': const Color(0xFFF447D1)},
      {'nama': 'Liburan', 'warna': const Color(0xFFF8877F)},
      {'nama': 'Hiburan', 'warna': const Color(0xFFFB83B3)},
      {'nama': 'Lainnya', 'warna': const Color(0xFFFFFF00)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: currentUser == null
            ? Center(child: Text("Silakan login terlebih dahulu", style: GoogleFonts.poppins()))
            : StreamBuilder<QuerySnapshot>(
                // Mendengarkan data secara real-time dari Firestore
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('transactions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Terjadi kesalahan", style: GoogleFonts.poppins()));
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

                  // --- SYSTEM PERHITUNGAN OTOMATIS DARI FIREBASE ---
                  int totalPemasukan = 0;
                  int totalPengeluaran = 0;

                  for (var doc in docs) {
                    Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                    int nominal = 0;
                    if (item['nominal'] is int) {
                      nominal = item['nominal'];
                    } else {
                      nominal = int.tryParse(item['nominal'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    }

                    if (item['tipe'] == 'pemasukan') {
                      totalPemasukan += nominal;
                    } else if (item['tipe'] == 'pengeluaran') {
                      totalPengeluaran += nominal;
                    }
                  }

                  // Hitung tinggi diagram batang secara proporsional (Max tinggi bar = 100)
                  double maxTinggiBar = 80.0;
                  double tinggiBarPemasukan = 0.0;
                  double tinggiBarPengeluaran = 0.0;

                  int maxNominal = totalPemasukan > totalPengeluaran ? totalPemasukan : totalPengeluaran;
                  if (maxNominal > 0) {
                    tinggiBarPemasukan = (totalPemasukan / maxNominal) * maxTinggiBar;
                    tinggiBarPengeluaran = (totalPengeluaran / maxNominal) * maxTinggiBar;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================== CARD 1: DIAGRAM BATANG ====================
                        Container(
                          width: double.infinity,
                          height: 195,
                          decoration: BoxDecoration(
                            color: const Color(0xFF112D4E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "PEMASUKAN PENGELUARAN",
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
                                  ),
                                  Text(
                                    _getCurrentMonthYear(), // Menggunakan data bulan dinamis
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Kolom Pemasukan
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rp +${_formatRupiah(totalPemasukan)}",
                                        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4FFBDF)),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 110,
                                        height: tinggiBarPemasukan < 15 ? 15 : tinggiBarPemasukan,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4FFBDF),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "+Pemasukan",
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF4FFBDF)),
                                      ),
                                    ],
                                  ),
                                  
                                  // Kolom Pengeluaran
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rp -${_formatRupiah(totalPengeluaran)}",
                                        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 110,
                                        height: tinggiBarPengeluaran < 15 ? 15 : tinggiBarPengeluaran,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "-Pengeluaran",
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // ==================== CARD 2: KATEGORI PENGELUARAN ====================
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF112D4E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "KATEGORI PENGELUARAN",
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
                              ),
                              const SizedBox(height: 20),
                              
                              // Loop menggunakan daftarKategori
                              ...daftarKategori.map((kategori) {
                                String namaKat = kategori['nama'];
                                Color warnaKat = kategori['warna'];

                                // Hitung total pengeluaran khusus kategori ini DARI FIREBASE
                                int totalKategori = 0;
                                for (var doc in docs) {
                                  Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                                  
                                  // Mengatasi perbedaan huruf besar/kecil dan spasi
                                  String katDatabase = (item['kategori'] ?? '').toString().toLowerCase().trim();
                                  String katLokal = namaKat.toLowerCase().trim();
                                  // Khusus untuk menoleransi jika ada kategori "Lainnya (Pengeluaran)" di database
                                  if (katLokal == 'lainnya' && katDatabase.contains('lainnya')) {
                                    katDatabase = 'lainnya'; 
                                  }

                                  if (item['tipe'] == 'pengeluaran' && katDatabase == katLokal) {
                                    int nominal = 0;
                                    if (item['nominal'] is int) {
                                      nominal = item['nominal'];
                                    } else {
                                      nominal = int.tryParse(item['nominal'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                                    }
                                    totalKategori += nominal;
                                  }
                                }

                                // Hitung persen berdasarkan total pemasukan
                                int persentase = 0;
                                if (totalPemasukan > 0) {
                                  persentase = ((totalKategori / totalPemasukan) * 100).round();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            namaKat,
                                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "Rp -${_formatRupiah(totalKategori)}",
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 35,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "$persentase%",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14, 
                                                  fontWeight: FontWeight.w500, 
                                                  color: warnaKat,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Rectangle Bar Statistik Berjalan
                                      Container(
                                        width: double.infinity,
                                        height: 11,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: persentase > 100 ? 100 : (persentase == 0 ? 0 : persentase),
                                              child: persentase == 0 
                                                  ? const SizedBox() // Kosongkan jika 0%
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color: warnaKat,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              flex: (100 - (persentase > 100 ? 100 : persentase)),
                                              child: const SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
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