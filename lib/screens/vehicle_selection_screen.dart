import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'tracking_screen.dart';

class VehicleSelectionPage extends StatefulWidget {
  const VehicleSelectionPage({super.key});

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage>
    with TickerProviderStateMixin {
  String? selectedVehicle;
  String? selectedText;
  IconData? selectedIcon;
  late AnimationController _controller;
  late AnimationController _bgController;
  bool isDarkMode = false;

  // 🔹 Mapping kendaraan → fuelType
  final Map<String, String> vehicleFuelType = {
    "Mobil CC Kecil (≤1500 cc)": "Bensin",
    "Mobil CC Besar (>2000 cc)": "Bensin",
    "Mobil Solar Kecil (≤1500 cc)": "Solar",
    "Mobil Solar Besar (>2000 cc)": "Solar",
    "Mobil Listrik": "Listrik",
    "Motor CC Kecil (≤150 cc)": "Bensin",
    "Motor CC Besar (>250 cc)": "Bensin",
    "Motor Listrik": "Listrik",
    "Truk (Solar)": "Solar",
    "Bus BBM": "Solar",
    "Bus Gas": "Gas",
    "Bus Listrik": "Listrik",
    "Sepeda": "Non-Emisi",
  };

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // 🔹 Sub-menu kendaraan
  Future<void> _showSubOptions(String category, List<String> options, IconData icon) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text("Pilih $category"),
        children: options
            .map((opt) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, opt),
          child: Text(opt),
        ))
            .toList(),
      ),
    );

    if (choice != null) {
      setState(() {
        selectedVehicle = choice;
        selectedText = "$choice dipilih";
        selectedIcon = icon;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Kendaraan Dipilih"),
          content: Text("Anda memilih: $choice"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌱 Background animasi
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
                // 🔹 AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Pilih Kendaraan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.yellowAccent,
                        ),
                        onPressed: () =>
                            setState(() => isDarkMode = !isDarkMode),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.redAccent, size: 26),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Grid kendaraan
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildVehicleCard("Mobil (Bensin)", Icons.directions_car,
                          Colors.green, onTap: () {
                            _showSubOptions("Mobil (BBM)", [
                              "Mobil CC Kecil (≤1500 cc)",
                              "Mobil CC Besar (>2000 cc)"
                            ], Icons.directions_car);
                          }),
                      _buildVehicleCard("Mobil (Solar)", Icons.local_gas_station,
                          Colors.teal, onTap: () {
                            _showSubOptions("Mobil (Solar)", [
                              "Mobil Solar Kecil (≤1500 cc)",
                              "Mobil Solar Besar (>2000 cc)"
                            ], Icons.local_gas_station);
                          }),
                      _buildVehicleCard("Mobil Listrik", Icons.ev_station,
                          Colors.lightGreen, onTap: () {
                            setState(() {
                              selectedVehicle = "Mobil Listrik";
                              selectedText = "Mobil Listrik dipilih";
                              selectedIcon = Icons.ev_station;
                            });
                          }),
                      _buildVehicleCard("Motor (Bensin)", Icons.motorcycle,
                          Colors.green.shade700, onTap: () {
                            _showSubOptions("Motor (BBM)", [
                              "Motor CC Kecil (≤150 cc)",
                              "Motor CC Besar (>250 cc)"
                            ], Icons.motorcycle);
                          }),
                      _buildVehicleCard("Motor Listrik", Icons.electric_bike,
                          Colors.cyan, onTap: () {
                            setState(() {
                              selectedVehicle = "Motor Listrik";
                              selectedText = "Motor Listrik dipilih";
                              selectedIcon = Icons.electric_bike;
                            });
                          }),
                      _buildVehicleCard("Truk (Solar)", Icons.fire_truck,
                          Colors.teal.shade700, onTap: () {
                            setState(() {
                              selectedVehicle = "Truk (Solar)";
                              selectedText = "Truk (Solar) dipilih";
                              selectedIcon = Icons.fire_truck;
                            });
                          }),
                      _buildVehicleCard("Bus", Icons.directions_bus,
                          Colors.green.shade800, onTap: () {
                            _showSubOptions("Bus", [
                              "Bus BBM",
                              "Bus Gas",
                              "Bus Listrik"
                            ], Icons.directions_bus);
                          }),
                      _buildVehicleCard("Sepeda", Icons.pedal_bike, Colors.orange,
                          onTap: () {
                            setState(() {
                              selectedVehicle = "Sepeda";
                              selectedText = "Sepeda dipilih";
                              selectedIcon = Icons.pedal_bike;
                            });
                          }),
                    ],
                  ),
                ),

                if (selectedText != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedIcon != null)
                          Icon(selectedIcon, color: Colors.white, size: 26),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            selectedText!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 🔹 Tombol lanjutkan
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: selectedVehicle == null
                        ? null
                        : () {
                      _navigateTo(
                        TrackingScreen(
                          vehicle: selectedVehicle!,
                          fuelType: vehicleFuelType[selectedVehicle] ?? "",
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: selectedVehicle == null
                          ? Colors.grey
                          : Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 6,
                    ),
                    child: const Text(
                      "Lanjutkan",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // 🌱 Card kendaraan
  Widget _buildVehicleCard(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    final isSelected = selectedVehicle == title;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        color: isSelected
            ? color
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
              child:
              Icon(icon, size: 60, color: isSelected ? Colors.white : color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}