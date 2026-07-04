import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticPage extends StatefulWidget {
  final List<Map<String, dynamic>>? transaksi;

  const StatisticPage({super.key, this.transaksi});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Variabel penentu bulan dan tahun yang sedang aktif dilihat user
  DateTime _selectedDate = DateTime.now(); 

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

  // Helper untuk mengubah tanggal menjadi teks Bulan & Tahun
  String _getFormattedMonthYear(DateTime date) {
    const List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  // ==================== FUNGSI UBAH BULAN ====================
  void _prevMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    DateTime now = DateTime.now();
    // Proteksi ekstra: Jangan izinkan maju jika sudah berada di bulan saat ini
    if (_selectedDate.year == now.year && _selectedDate.month == now.month) {
      return; 
    }
    
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  // Helper membaca tipe tanggal dari Firebase
  DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    if (dateData is Timestamp) return dateData.toDate();
    if (dateData is String) {
      try { return DateTime.parse(dateData); } catch (e) { return null; }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> daftarKategori = [
      {'nama': 'Makan', 'warna': const Color(0xFFFFAD2A)},
      {'nama': 'Belanja', 'warna': const Color(0xFF77E68A)},
      {'nama': 'Transportasi', 'warna': const Color(0xFF3CBEFC)},
      {'nama': 'Rumah', 'warna': const Color(0xFFF447D1)},
      {'nama': 'Liburan', 'warna': const Color(0xFFF8877F)},
      {'nama': 'Hiburan', 'warna': const Color(0xFFFB83B3)},
      {'nama': 'Lainnya', 'warna': const Color(0xFFFFFF00)},
    ];

    // Cek apakah tanggal yang dipilih adalah bulan ini (untuk menyembunyikan tombol next)
    DateTime waktuSekarang = DateTime.now();
    bool isBulanIni = (_selectedDate.year == waktuSekarang.year && _selectedDate.month == waktuSekarang.month);

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
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Terjadi kesalahan", style: GoogleFonts.poppins()));
                  }

                  List<QueryDocumentSnapshot> allDocs = snapshot.data?.docs ?? [];

                  // ==================== SISTEM FILTER BULAN ====================
                  List<QueryDocumentSnapshot> filteredDocs = allDocs.where((doc) {
                    Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                    
                    var tanggalData = item['tanggal'] ?? item['date'] ?? item['createdAt'];
                    DateTime? itemDate = _parseDate(tanggalData);
                    
                    if (itemDate != null) {
                      return itemDate.month == _selectedDate.month && itemDate.year == _selectedDate.year;
                    }
                    return false; 
                  }).toList();

                  int totalPemasukan = 0;
                  int totalPengeluaran = 0;

                  for (var doc in filteredDocs) {
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

                  double maxTinggiBar = 80.0;
                  double tinggiBarPemasukan = 0.0;
                  double tinggiBarPengeluaran = 0.0;

                  int maxNominal = totalPemasukan > totalPengeluaran ? totalPemasukan : totalPengeluaran;
                  if (maxNominal > 0) {
                    tinggiBarPemasukan = (totalPemasukan / maxNominal) * maxTinggiBar;
                    tinggiBarPengeluaran = (totalPengeluaran / maxNominal) * maxTinggiBar;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 41,
                          color: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.only(left: 20, top: 5),
                          child: Image.asset('assets/logo_kasku.png', width: 103, height: 26, alignment: Alignment.centerLeft),
                        ),
                        const SizedBox(height: 20),
                        
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
                                    "STATISTIK BULANAN",
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
                                  ),
                                  // Navigasi Bulan Interaktif
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _prevMonth,
                                        child: const Icon(Icons.chevron_left, color: Color(0xFFDBE2EF), size: 24),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getFormattedMonthYear(_selectedDate),
                                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFDBE2EF)),
                                      ),
                                      const SizedBox(width: 4),
                                      
                                      // LOGIKA TOMBOL NEXT (Hilang jika berada di bulan saat ini)
                                      isBulanIni 
                                        ? const SizedBox(width: 24) // Kotak kosong agar teks tidak bergeser posisinya
                                        : GestureDetector(
                                            onTap: _nextMonth,
                                            child: const Icon(Icons.chevron_right, color: Color(0xFFDBE2EF), size: 24),
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
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
                                        height: tinggiBarPemasukan < 15 && totalPemasukan > 0 ? 15 : tinggiBarPemasukan,
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
                                        height: tinggiBarPengeluaran < 15 && totalPengeluaran > 0 ? 15 : tinggiBarPengeluaran,
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
                              
                              ...daftarKategori.map((kategori) {
                                String namaKat = kategori['nama'];
                                Color warnaKat = kategori['warna'];

                                int totalKategori = 0;
                                for (var doc in filteredDocs) {
                                  Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                                  
                                  String katDatabase = (item['kategori'] ?? '').toString().toLowerCase().trim();
                                  String katLokal = namaKat.toLowerCase().trim();
                                  
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

                                int persentase = 0;
                                if (totalPemasukan > 0) { 
                                  persentase = ((totalKategori / totalPemasukan) * 100).round();
                                  if (persentase > 100) {
                                    persentase = 100;
                                  }
                                } else if (totalPemasukan == 0 && totalKategori > 0) {
                                  persentase = 100;
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
                                              flex: persentase == 0 ? 0 : persentase,
                                              child: persentase == 0 
                                                  ? const SizedBox()
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color: warnaKat,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              flex: (100 - persentase),
                                              child: const SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
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