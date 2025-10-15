import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RiwayatPerjalananPage extends StatefulWidget {
  const RiwayatPerjalananPage({super.key});

  @override
  State<RiwayatPerjalananPage> createState() => _RiwayatPerjalananPageState();
}

class _RiwayatPerjalananPageState extends State<RiwayatPerjalananPage> {
  bool isPerjalananSelected = true;

  // 💾 Data dummy
  final List<Map<String, dynamic>> perjalananData = [
    {
      'vehicle': 'Mobil',
      'fuelType': 'Bensin',
      'duration': '45 menit',
      'distance': 18.5,
      'emission': 4.2,
      'date': '12 Okt 2025',
    },
    {
      'vehicle': 'Motor',
      'fuelType': 'Pertalite',
      'duration': '20 menit',
      'distance': 8.1,
      'emission': 1.7,
      'date': '10 Okt 2025',
    },
  ];

  final List<Map<String, dynamic>> offsetData = [
    {
      'project': 'Penanaman Pohon Mangrove',
      'location': 'Batam Centre',
      'amount': 'Rp 50.000',
      'date': '5 Okt 2025',
    },
    {
      'project': 'Donasi Energi Hijau',
      'location': 'Tiban Lama',
      'amount': 'Rp 25.000',
      'date': '1 Okt 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF5E936C);
    const inactiveGray = Color(0xFFD9D9D9);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F6),
      body: Stack(
        children: [
          // 🖼️ Header SVG sebagai background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/header.svg',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),

          // 🌿 Konten utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏷️ Header Text + Tombol Notifikasi
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Riwayat",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // aksi ketika tombol notifikasi ditekan
                        },
                        icon: const Icon(Icons.notifications_none),
                        color: Colors.white,
                        iconSize: 26,
                      ),
                    ],
                  ),
                ),

                // 🔘 Toggle Button (digeser agar pas di bawah header SVG)
                Container(
                  transform: Matrix4.translationValues(0, 20, 0),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 95),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isPerjalananSelected = true);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isPerjalananSelected
                                    ? primaryGreen
                                    : inactiveGray,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Perjalanan",
                                style: GoogleFonts.poppins(
                                  color: isPerjalananSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isPerjalananSelected = false);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: !isPerjalananSelected
                                    ? primaryGreen
                                    : inactiveGray,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Offset",
                                style: GoogleFonts.poppins(
                                  color: !isPerjalananSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40), // jarak antar toggle & isi list

                // 📋 Daftar Riwayat
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isPerjalananSelected
                        ? _buildPerjalananList()
                        : _buildOffsetList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛣️ Daftar Perjalanan
  Widget _buildPerjalananList() {
    return ListView.builder(
      itemCount: perjalananData.length,
      itemBuilder: (context, index) {
        final item = perjalananData[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item['vehicle']} - ${item['fuelType']}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Durasi: ${item['duration']}\nJarak: ${item['distance']} km\nEmisi: ${item['emission']} kg CO₂",
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5E936C),
                      ),
                      child: Text(
                        "Detail",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌱 Daftar Offset
  Widget _buildOffsetList() {
    return ListView.builder(
      itemCount: offsetData.length,
      itemBuilder: (context, index) {
        final item = offsetData[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['project'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Lokasi: ${item['location']}\nJumlah: ${item['amount']}",
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5E936C),
                      ),
                      child: Text(
                        "Detail",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
