import 'package:flutter/material.dart';
import 'tracking_screen.dart';
import 'login_screen.dart';

class FuelSelectionPage extends StatefulWidget {
  final String selectedVehicle;

  const FuelSelectionPage({super.key, required this.selectedVehicle});

  @override
  State<FuelSelectionPage> createState() => _FuelSelectionPageState();
}

class _FuelSelectionPageState extends State<FuelSelectionPage>
    with TickerProviderStateMixin {
  String? selectedFuel;
  bool isDarkMode = false;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌱 Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                      Color.lerp(Colors.black, Colors.green.shade900,
                          _bgController.value)!,
                      Color.lerp(Colors.black87, Colors.teal.shade900,
                          _bgController.value)!,
                    ]
                        : [
                      Color.lerp(Colors.green, Colors.lightGreen,
                          _bgController.value)!,
                      Color.lerp(Colors.teal, Colors.greenAccent,
                          _bgController.value)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔹 Custom AppBar
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Pilih Bahan Bakar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.yellowAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            isDarkMode = !isDarkMode;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.redAccent, size: 26),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Grid pilihan bahan bakar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFuelCard("Bensin", Icons.local_gas_station),
                        _buildFuelCard("Solar", Icons.oil_barrel),
                       ],
                    ),
                  ),
                ),

                // 🔹 Tombol Lanjutkan
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFuel == null
                          ? Colors.grey
                          : Colors.green.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    onPressed: selectedFuel == null
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackingScreen(
                            vehicle: widget.selectedVehicle,
                            fuelType: selectedFuel!,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Lanjutkan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌱 Card Bahan Bakar
  Widget _buildFuelCard(String title, IconData icon) {
    final isSelected = selectedFuel == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFuel = title;
        });

        // 🎉 Snackbar Info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$title dipilih"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        color: isSelected
            ? Colors.green.shade700
            : (isDarkMode ? Colors.grey.shade900 : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white24
                    : (isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                size: 60,
                color: isSelected ? Colors.white : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}