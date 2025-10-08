import 'package:flutter/material.dart';

// Import semua screen
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vehicle_selection_screen.dart';
import 'screens/fuel_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/riwayat_perjalanan_page.dart'; // ✅ halaman riwayat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking App',
      debugShowCheckedModeBanner: false,

      // ✅ langsung masuk ke login dulu
      initialRoute: "/login",

      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomeScreen(),
        "/vehicle": (context) => const VehicleSelectionPage(),
        "/fuel": (context) => const FuelSelectionPage(selectedVehicle: ''),
        "/tracking": (context) =>
        const TrackingScreen(vehicle: '', fuelType: ''),
        "/riwayat": (context) => const RiwayatPerjalananPage(),
      },
    );
  }
}