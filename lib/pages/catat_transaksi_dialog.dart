import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// --- TAMBAHAN IMPORT FIREBASE ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatatTransaksiDialog extends StatefulWidget {
  final Map<String, dynamic>? transaksiLama;

  const CatatTransaksiDialog({super.key, this.transaksiLama});
  
  @override
  State<CatatTransaksiDialog> createState() => _CatatTransaksiDialogState();
}

class _CatatTransaksiDialogState extends State<CatatTransaksiDialog> {
  // Sistem State: Pemasukan (true) atau Pengeluaran (false)
  bool isPemasukan = true;

  // Controller untuk Input
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  String tipeTransaksi = "pengeluaran";
  
  @override
  void initState() {
    super.initState();
    // JIKA ADA DATA LAMA (Mode Edit), ISI KE FORM
    if (widget.transaksiLama != null) {
      nominalController.text = widget.transaksiLama!['nominal'];
      catatanController.text = widget.transaksiLama!['note'];
      tipeTransaksi = widget.transaksiLama!['tipe'];
      isPemasukan = tipeTransaksi == "pemasukan";
    }
  }

  String? selectedKategori;
  DateTime? selectedTanggal;

  // Sistem: Kategori berbeda untuk Pemasukan dan Pengeluaran
  final List<String> kategoriPemasukan = [
    'Uang Saku', 'Gaji', 'Pekerjaan Tidak Tetap', 'Pensiun', 'Lainnya (Pemasukan)'
  ];
  final List<String> kategoriPengeluaran = [
    'Makan', 'Belanja', 'Transportasi', 'Rumah', 'Liburan', 'Hiburan', 'Lainnya (Pengeluaran)'
  ];

  // Format Tanggal untuk ditampilkan di UI
  String get tanggalFormatted {
    if (selectedTanggal == null) return "Masukkan Tanggal";
    return DateFormat('yyyy-MM-dd').format(selectedTanggal!);
  }
  
  // Sistem: Pemetaan nama kategori ke file gambar di assets
  String _getIconPath(String? kategori) {
    switch (kategori) {
      // 5 Pemasukan
      case 'Uang Saku': return 'assets/uang_saku.png';
      case 'Gaji': return 'assets/gaji.png';
      case 'Pekerjaan Tidak Tetap': return 'assets/pekerjaan.png';
      case 'Pensiun': return 'assets/pensiun.png';
      case 'Lainnya (Pemasukan)': return 'assets/lain_masuk.png';
      // 7 Pengeluaran
      case 'Makan': return 'assets/makan.png';
      case 'Belanja': return 'assets/belanja.png';
      case 'Transportasi': return 'assets/transportasi.png';
      case 'Rumah': return 'assets/rumah.png';
      case 'Liburan': return 'assets/liburan.png';
      case 'Hiburan': return 'assets/hiburan.png';
      case 'Lainnya (Pengeluaran)': return 'assets/lain_keluar.png';
      
      default: return 'assets/logo_kasku.png'; // Gambar cadangan jika terjadi error
    }
  }
  
  // Sistem: Menyimpan Transaksi (Diubah menjadi async untuk Firebase)
  // Sistem: Menyimpan Transaksi (Diubah menjadi async untuk Firebase)
  Future<void> _simpanTransaksi() async {
    // Validasi Minimal 3 Data Wajib Terisi
    if (nominalController.text.isEmpty || selectedKategori == null || selectedTanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nominal, Kategori, dan Tanggal wajib diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    String tipe = isPemasukan ? "pemasukan" : "pengeluaran";
    String finalNote = catatanController.text.isEmpty ? "Note" : catatanController.text;

    // --- CEK MODE: TAMBAH ATAU EDIT? ---
    // Jika widget.transaksiLama == null, berarti ini MODE TAMBAH BARU
    if (widget.transaksiLama == null) {
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('transactions')
              .add({
            "tipe": tipe,
            "nominal": int.tryParse(nominalController.text) ?? 0, 
            "kategori": selectedKategori,
            "tanggal": selectedTanggal, 
            "tanggal_string": tanggalFormatted,
            "note": finalNote,
            "iconPath": _getIconPath(selectedKategori),
            "timestamp": FieldValue.serverTimestamp(), 
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal menyimpan ke database: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return; // Hentikan eksekusi jika gagal
        }
      }
    }
    // Jika widget.transaksiLama != null (MODE EDIT), 
    // Kita TIDAK melakukan .add() di sini, karena .update() sudah diurus oleh RiwayatPage.

    // Mengembalikan data ke halaman yang memanggil (Berlaku untuk Tambah & Edit)
    if (mounted) {
      Navigator.pop(context, {
        "tipe": tipe,
        "nominal": nominalController.text,
        "kategori": selectedKategori,
        "tanggal": tanggalFormatted,
        "note": finalNote,
        "iconPath": _getIconPath(selectedKategori), 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Container(
        width: 366,
        height: 708,
        decoration: BoxDecoration(
          color: const Color(0xFF112D4E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.only(left: 23, top: 30),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF112D4E), size: 20),
                    ),
                  ),
                  const SizedBox(width: 33),
                  Text(
                    "Catat Transaksi",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDBE2EF),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: 366,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F7F7),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                    bottom: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildToggleButton(
                            label: "Pemasukan",
                            isActive: isPemasukan,
                            activeColor: const Color(0xFF4FFBDF),
                            onTap: () {
                              setState(() {
                                isPemasukan = true;
                                selectedKategori = null;
                              });
                            },
                          ),
                          _buildToggleButton(
                            label: "Pengeluaran",
                            isActive: !isPemasukan,
                            activeColor: const Color(0xFFEF4444),
                            onTap: () {
                              setState(() {
                                isPemasukan = false;
                                selectedKategori = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      _buildLabel("NOMINAL (Rp)"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: nominalController,
                        hint: "Masukkan nominal (Rp)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("KATEGORI"),
                      const SizedBox(height: 10),
                      _buildDropdownKategori(),
                      const SizedBox(height: 15),

                      _buildLabel("TANGGAL"),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedTanggal = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F7F7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFDBE2EF), width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tanggalFormatted,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedTanggal == null ? const Color(0xFFDBE2EF) : Colors.black,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("CATATAN"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: catatanController,
                        hint: "Masukkan Catatan Max.40",
                        maxLength: 40,
                      ),
                      const SizedBox(height: 30),

                      GestureDetector(
                        onTap: _simpanTransaksi,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF112D4E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Simpan Transaksi",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER BANTUAN ---
  Widget _buildToggleButton({required String label, required bool isActive, required Color activeColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 152,
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFDBE2EF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF112D4E),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF000000)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF)),
        filled: true,
        fillColor: const Color(0xFFF9F7F7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFDBE2EF), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF112D4E), width: 2),
        ),
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildDropdownKategori() {
    List<String> activeCategories = isPemasukan ? kategoriPemasukan : kategoriPengeluaran;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBE2EF), width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedKategori,
          hint: Text("Masukkan Kategori", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFDBE2EF))),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: activeCategories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedKategori = newValue;
            });
          },
        ),
      ),
    );
  }
}