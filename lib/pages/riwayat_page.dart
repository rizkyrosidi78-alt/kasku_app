import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kasku_app/pages/catat_transaksi_dialog.dart';
// --- TAMBAHAN IMPORT FIREBASE ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatPage extends StatefulWidget {
  // Dibuat opsional agar tidak membuat error di MainNavigation yang masih mengirim dummy data
  final List<Map<String, dynamic>>? transaksi;
  final Function(String)? onHapus;
  final Function(Map<String, dynamic>)? onEdit;

  const RiwayatPage({
    super.key, 
    this.transaksi, 
    this.onHapus,
    this.onEdit,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // --- STATE UNTUK FILTER ---
  String _selectedTipe = 'pemasukan'; 
  String _selectedKategori = 'Semua'; 

  final List<String> _kategoriPemasukan = ['Semua', 'Uang Saku', 'Gaji', 'Pekerjaan Tidak Tetap', 'Pensiun', 'Lainnya (Pemasukan)'];
  final List<String> _kategoriPengeluaran = ['Semua', 'Makan', 'Belanja', 'Transportasi', 'Rumah', 'Liburan', 'Hiburan', 'Lainnya (Pengeluaran)'];

  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fungsi Format Rupiah (Disesuaikan karena dari Firebase nominal berupa integer)
  String _formatRupiah(dynamic nominal) {
    int parsed = 0;
    if (nominal is int) {
      parsed = nominal;
    } else if (nominal is String) {
      parsed = int.tryParse(nominal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return NumberFormat.decimalPattern('id').format(parsed);
  }

  // Fungsi Hapus Transaksi Langsung dari Database
  Future<void> _hapusTransaksiDatabase(String docId) async {
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('transactions')
            .doc(docId)
            .delete();
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil dihapus'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentKategoriList = _selectedTipe == 'pemasukan' ? _kategoriPemasukan : _kategoriPengeluaran;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (Logo) ---
            Container(
              width: double.infinity,
              height: 41,
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Image.asset('assets/logo_kasku.png', width: 103, height: 26, alignment: Alignment.centerLeft),
            ),
            const SizedBox(height: 20),

            // --- FILTER TIPE (Pemasukan & Pengeluaran) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTipeButton('Pemasukan', 'pemasukan', const Color(0xFF4FFBDF)),
                const SizedBox(width: 41),
                _buildTipeButton('Pengeluaran', 'pengeluaran', const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 15),

            // --- FILTER KATEGORI (Scroll Horizontal) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: currentKategoriList.map((kategori) => _buildKategoriButton(kategori)).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- DAFTAR TRANSAKSI (StreamBuilder Firebase) ---
            Expanded(
              child: currentUser == null 
                  ? Center(child: Text("Silakan login terlebih dahulu", style: GoogleFonts.poppins()))
                  : StreamBuilder<QuerySnapshot>(
                      // Mendengarkan data dari koleksi transactions milik user yang login
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('transactions')
                          .orderBy('timestamp', descending: true) // Urutkan terbaru
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text("Terjadi kesalahan sistem", style: GoogleFonts.poppins()));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "Belum ada data transaksi tersimpan.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                            ),
                          );
                        }

                        // Memetakan dokumen Firebase ke bentuk List Map agar mudah difilter
                        List<Map<String, dynamic>> allTransaksi = snapshot.data!.docs.map((doc) {
                          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                          data['id'] = doc.id; // Menyisipkan ID Dokumen Firebase untuk edit/hapus
                          return data;
                        }).toList();

                        // Proses Filter Data sesuai pilihan Tipe dan Kategori
                        List<Map<String, dynamic>> filteredTransaksi = allTransaksi.where((item) {
                          bool isTipeMatch = item['tipe'] == _selectedTipe;
                          bool isKategoriMatch = _selectedKategori == 'Semua' || item['kategori'] == _selectedKategori;
                          return isTipeMatch && isKategoriMatch;
                        }).toList();

                        if (filteredTransaksi.isEmpty) {
                          return Center(
                            child: Text(
                              "Tidak ada riwayat transaksi\nuntuk kategori ini.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: filteredTransaksi.length,
                          itemBuilder: (context, index) {
                            final item = filteredTransaksi[index];
                            bool isIncome = item['tipe'] == 'pemasukan';
                            String formattedNominal = "${isIncome ? '+' : '-'}${_formatRupiah(item['nominal'])}";
                            
                            // Menentukan warna kartu ikon berdasarkan tipe
                            Color iconBgColor = isIncome ? const Color(0xFF4FFBDF) : const Color(0xFFEF4444);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              width: double.infinity,
                              height: 63,
                              decoration: BoxDecoration(color: const Color(0xFFDBE2EF), borderRadius: BorderRadius.circular(24)),
                              child: Row(
                                children: [
                                  const SizedBox(width: 21),
                                  // Ikon Kategori
                                  Container(
                                    width: 33, height: 36,
                                    decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8.5)),
                                    padding: const EdgeInsets.all(2),
                                    child: Image.asset(
                                      item['iconPath'] ?? 'assets/logo_kasku.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Judul & Catatan
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['kategori'] ?? 'Kategori', 
                                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
                                        ),
                                        Text(
                                          (item['note'] ?? '').toString().length > 30 
                                              ? '${item['note'].toString().substring(0, 30)}...' 
                                              : item['note'] ?? '',
                                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Nominal & Tanggal
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rp $formattedNominal",
                                        style: GoogleFonts.roboto(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w700,
                                          color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444), // Warna hijau/merah
                                        ),
                                      ),
                                      Text(
                                        item['tanggal_string'] ?? 'Tanggal', 
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
                                      ),
                                    ],
                                  ),
                                  // Tombol Titik Tiga (Menu Hapus & Edit)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Color(0xFF112D4E)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (String value) async {
                                      if (value == 'edit') {
                                        // Buka dialog untuk edit
                                        final hasilEdit = await showDialog(
                                          context: context,
                                          builder: (context) => CatatTransaksiDialog(
                                            // Mempersiapkan data untuk dilempar ke form agar diisi otomatis
                                            transaksiLama: {
                                              'tipe': item['tipe'],
                                              'nominal': item['nominal'].toString(), // Ubah jadi string untuk TextField
                                              'note': item['note'],
                                            },
                                          ),
                                        );

                                        // Jika user menekan tombol simpan
                                        if (hasilEdit != null) {
                                          try {
                                            // Lakukan Update ke Firebase
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser!.uid)
                                                .collection('transactions')
                                                .doc(item['id']) // Menggunakan ID dokumen spesifik
                                                .update({
                                              "tipe": hasilEdit['tipe'],
                                              "nominal": int.tryParse(hasilEdit['nominal'].toString()) ?? 0,
                                              "kategori": hasilEdit['kategori'],
                                              "tanggal_string": hasilEdit['tanggal'],
                                              "note": hasilEdit['note'],
                                              "iconPath": hasilEdit['iconPath'],
                                            });

                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Transaksi berhasil diupdate!')),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
                                              );
                                            }
                                          }
                                        }
                                      } else if (value == 'hapus') {
                                        _hapusTransaksiDatabase(item['id']);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [const Icon(Icons.edit, size: 18, color: Colors.blue), const SizedBox(width: 8), Text('Edit', style: GoogleFonts.poppins())]),
                                      ),
                                      PopupMenuItem(
                                        value: 'hapus',
                                        child: Row(children: [const Icon(Icons.delete, size: 18, color: Colors.red), const SizedBox(width: 8), Text('Hapus', style: GoogleFonts.poppins())]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Tombol Pemasukan / Pengeluaran
  Widget _buildTipeButton(String title, String type, Color activeColor) {
    bool isActive = _selectedTipe == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTipe = type;
          _selectedKategori = 'Semua';
        });
      },
      child: Container(
        width: 152,
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFDBE2EF), 
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF112D4E),
          ),
        ),
      ),
    );
  }

  // Helper Widget: Tombol Kategori
  Widget _buildKategoriButton(String kategori) {
    bool isActive = _selectedKategori == kategori;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedKategori = kategori;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF112D4E) : const Color(0xFFDBE2EF),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          kategori,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFFDBE2EF) : const Color(0xFF112D4E),
          ),
        ),
      ),
    );
  }
}