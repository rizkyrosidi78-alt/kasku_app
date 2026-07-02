import 'package:flutter/material.dart';
import 'home_page.dart';
import 'riwayat_page.dart';
import 'catat_transaksi_dialog.dart';
import 'statistic_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 1. MASTER DATA TRANSAKSI
  // Semua data tersimpan di sini, jadi Home dan Riwayat akan selalu sinkron.
  final List<Map<String, dynamic>> _transaksiMaster = [
    {
      "id": "1",
      "kategori": "Uang Saku",
      "note": "Note",
      "nominal": "700000",
      "tanggal": "2026-06-23",
      "tipe": "pemasukan",
      "iconPath": "assets/uang_saku.png",
      "color": Colors.green[400],
    },
    {
      "id": "2",
      "kategori": "Makan",
      "note": "Makan siang warung",
      "nominal": "35000",
      "tanggal": "2026-06-23",
      "tipe": "pengeluaran",
      "iconPath": "assets/makan.png",
      "color": Colors.orange[400],
    },
    {
      "id": "3",
      "kategori": "Transportasi",
      "note": "Ojek ke kampus",
      "nominal": "20000",
      "tanggal": "2026-06-24",
      "tipe": "pengeluaran",
      "iconPath": "assets/transportasi.png",
      "color": Colors.blue[600],
    },
  ];

  // Fungsi untuk menghapus transaksi dari Master Data
  void _hapusTransaksi(String id) {
    setState(() {
      _transaksiMaster.removeWhere((item) => item['id'] == id);
    });
  }

  // Fungsi untuk memperbarui transaksi
  void _editTransaksi(Map<String, dynamic> transaksiUpdate) {
    setState(() {
      // Cari nomor urut (index) data yang id-nya sama dengan id yang mau diedit
      int index = _transaksiMaster.indexWhere((item) => item['id'] == transaksiUpdate['id']);
      
      // Jika ketemu, ganti data di urutan tersebut dengan data yang baru
      if (index != -1) {
        _transaksiMaster[index] = transaksiUpdate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. DAFTAR HALAMAN (ANAK)
    final List<Widget> pages = [
      HomePage(transaksi: _transaksiMaster), // Mengirim data ke Home
      RiwayatPage(
        transaksi: _transaksiMaster, 
        onHapus: _hapusTransaksi,
        onEdit: _editTransaksi, // <--- TAMBAHKAN BARIS INI
      ),
      StatisticPage(
        transaksi: _transaksiMaster
      ),
      ProfilePage(),      // Mengirim data & fungsi hapus ke Riwayat
      const Scaffold(body: Center(child: Text("Halaman Statistik"))),
      const Scaffold(body: Center(child: Text("Halaman Profile"))),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      
      // 3. TOMBOL TAMBAH (+) MENGAMBANG
      // 3. TOMBOL TAMBAH (+) MENGAMBANG
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF112D4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: () async {
          // Memanggil Dialog
          final hasilTransaksi = await showDialog(
            context: context,
            builder: (context) => const CatatTransaksiDialog(),
          );

          // Jika user menekan 'Simpan' dan ada datanya
          if (hasilTransaksi != null) {
            // SOLUSI: Ubah tipe data secara paksa menjadi dinamis agar bisa menerima Warna (Color)
            Map<String, dynamic> dataBaru = Map<String, dynamic>.from(hasilTransaksi);

            setState(() {
              // Berikan ID unik berupa timestamp waktu
              dataBaru['id'] = DateTime.now().millisecondsSinceEpoch.toString();
              
              // Tentukan warna ikon
              dataBaru['color'] = dataBaru["tipe"] == "pemasukan" 
                  ? const Color(0xFFDBE2EF) 
                  : const Color(0xFFDBE2EF);
              
              // Masukkan ke urutan paling atas
              _transaksiMaster.insert(0, dataBaru);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 4. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.receipt_long_outlined, 'Riwayat', 1),
              const SizedBox(width: 40), // Ruang kosong untuk tombol + di tengah
              _buildNavItem(Icons.pie_chart_outline, 'Statistik', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  // Desain Item Navbar
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF112D4E) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF112D4E) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}