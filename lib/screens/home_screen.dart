import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vehicle_selection_screen.dart';
import 'profile_screen.dart';
import 'donasi_simulasi_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = ""});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalEmission = 0.0;
  double _offsetEmission = 0.0;
  double _belumOffset = 0.0;
  int _currentIndex = 2;

  static const Color primaryGreen = Color(0xFF3E5F44); // 🌿 warna utama baru

  @override
  void initState() {
    super.initState();
    _loadEmissionData();
  }

  Future<void> _loadEmissionData() async {
    final prefs = await SharedPreferences.getInstance();
    final trips = prefs.getStringList('trip_history') ?? [];
    double sum = 0.0;

    for (var t in trips) {
      final trip = Map<String, dynamic>.from(jsonDecode(t));
      sum += (trip['emission'] as num).toDouble();
    }

    double offset = prefs.getDouble('totalOffset') ?? 0.0;
    double belumOffset = (sum - offset);
    if (belumOffset < 0) belumOffset = 0;

    setState(() {
      _totalEmission = sum;
      _offsetEmission = offset;
      _belumOffset = belumOffset;
    });
  }

  Future<void> _refreshAfterNavigate() async => _loadEmissionData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: primaryGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VehicleSelectionPage()),
            ).then((_) => _refreshAfterNavigate());
          } else if (index == 1) {
            Navigator.pushNamed(context, "/riwayat").then((_) => _refreshAfterNavigate());
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonasiSimulasiScreen(totalEmisi: _totalEmission),
              ),
            ).then((_) => _refreshAfterNavigate());
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(username: widget.username)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Tracking"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🌿 Header.svg dijadikan background atas
            Positioned.fill(
              top: 0,
              bottom: MediaQuery.of(context).size.height * 0.6, // hanya bagian atas
              child: SvgPicture.asset(
                'assets/header.svg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            // 🌿 Konten utama
            Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.username.isNotEmpty
                              ? "Hai, ${widget.username}!"
                              : "Selamat datang di EcoTrack",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔸 BODY PUTIH MELENGKUNG
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🌱 Total Emisi
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Emisi Karbon",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${_totalEmission.toStringAsFixed(2)} kg CO₂",
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🌿 Dua kotak statistik
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  "Telah di-offset",
                                  "${_offsetEmission.toStringAsFixed(2)} kg",
                                  primaryGreen.withOpacity(0.1),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatBox(
                                  "Belum di-offset",
                                  "${_belumOffset.toStringAsFixed(2)} kg",
                                  Colors.red.shade50,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 💚 Donasi Sekarang
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DonasiSimulasiScreen(totalEmisi: _totalEmission),
                                  ),
                                ).then((_) => _refreshAfterNavigate());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                "Donasi Sekarang",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600, // semibold
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 28),

                          // 🌍 Komunitas
                          Text(
                            "Komunitas",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildCommunityCard("Green Batam", "assets/komunitas1.png"),
                                _buildCommunityCard("Eco Forest ID", "assets/komunitas2.png"),
                                _buildCommunityCard("Nusantara Hijau", "assets/komunitas3.png"),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 🚗 Rekomendasi & Edukasi
                          Text(
                            "Rekomendasi & Edukasi",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Column(
                            children: [
                              _buildVehicleCard(
                                icon: Icons.directions_bike,
                                title: "Gunakan Sepeda",
                                desc:
                                    "Selain bebas emisi, bersepeda juga menyehatkan jantung dan paru-paru.",
                              ),
                              const SizedBox(height: 12),
                              _buildVehicleCard(
                                icon: Icons.directions_bus,
                                title: "Naik Transportasi Umum",
                                desc:
                                    "Berbagi kendaraan membantu menurunkan emisi karbon.",
                              ),
                              const SizedBox(height: 12),
                              _buildVehicleCard(
                                icon: Icons.energy_savings_leaf,
                                title: "Gunakan Energi Hijau",
                                desc:
                                    "Gunakan sumber energi terbarukan seperti panel surya.",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🧱 Widget kecil
  Widget _buildStatBox(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(String title, String img) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/komunitas", arguments: title),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryGreen, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.black54, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
