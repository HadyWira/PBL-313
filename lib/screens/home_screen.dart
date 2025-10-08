import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vehicle_selection_screen.dart';
import 'profile_screen.dart';
import 'donasi_simulasi_screen.dart';

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

    await prefs.setDouble('totalEmisiGlobal', sum);
    await prefs.setDouble('belumOffset', belumOffset);
  }

  Future<void> _resetEmission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trip_history');
    await prefs.remove('totalOffset');
    await prefs.remove('totalEmisiGlobal');
    await prefs.remove('belumOffset');
    setState(() {
      _totalEmission = 0.0;
      _offsetEmission = 0.0;
      _belumOffset = 0.0;
    });
  }

  Future<void> _refreshAfterNavigate() async {
    await _loadEmissionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      // 🌿 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF2E7D32),
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

      // 🌱 Body
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.username.isNotEmpty
                              ? "Hai, ${widget.username}! 🌱"
                              : "Selamat Datang di EcoTrack 🌱",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadEmissionData,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _resetEmission,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Emisi Karbon",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("${_totalEmission.toStringAsFixed(2)} kg CO₂",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Telah di-offset",
                                "${_offsetEmission.toStringAsFixed(2)} kg",
                                Colors.green.shade50,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Belum di-offset",
                                "${_belumOffset.toStringAsFixed(2)} kg",
                                Colors.red.shade50,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🌍 Konten bawah scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Ayo Donasikan karbonmu di komunitas ini",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonasiSimulasiScreen(totalEmisi: _totalEmission),
                            ),
                          ).then((_) => _refreshAfterNavigate());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 6,
                        ),
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        label: const Text(
                          "Donasi Sekarang",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCommunityCard("Komunitas Hijau Bandung", "assets/komunitas1.jpg"),
                          _buildCommunityCard("Eco Forest Indonesia", "assets/komunitas2.jpg"),
                          _buildCommunityCard("Tanam Pohon Nusantara", "assets/komunitas3.jpg"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("Rekomendasi Kendaraan",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // ✅ Sekarang rekomendasi kendaraan scroll horizontal
                    SizedBox(
                      height: 190, // 🔼 diperbesar dari 170 jadi 190
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildVehicleCard(
                            icon: Icons.directions_bus,
                            color: Colors.blue,
                            title: "Komuter 20 km/hari",
                            subtitle: "Hemat ±3.89 kg CO₂/hari",
                          ),
                          _buildVehicleCard(
                            icon: Icons.pedal_bike,
                            color: Colors.green,
                            title: "Sepeda",
                            subtitle: "0 kg CO₂/hari — baik untuk kesehatan",
                          ),
                          _buildVehicleCard(
                            icon: Icons.directions_walk,
                            color: Colors.orange,
                            title: "Jalan Kaki",
                            subtitle: "0 kg CO₂/hari — alternatif jarak dekat",
                          ),
                          _buildVehicleCard(
                            icon: Icons.electric_scooter,
                            color: Colors.purple,
                            title: "Motor Listrik",
                            subtitle: "±4 kg CO₂/hari — emisi rendah (±0.2 kg/km)",
                          ),
                          _buildVehicleCard(
                            icon: Icons.electric_car,
                            color: Colors.teal,
                            title: "Mobil Listrik",
                            subtitle: "±0.1 kg/km — lebih ramah daripada mobil konvensional",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(String title, String imagePath) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
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
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ),
    );
  }

  // 🔧 Widget tambahan untuk rekomendasi kendaraan (horizontal card)
  Widget _buildVehicleCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10), // 🔽 sedikit dikurangi padding biar lega
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 🔽 tombol diperkecil
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Pilih", style: TextStyle(fontSize: 12)), // 🔽 teks tombol juga lebih kecil
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}