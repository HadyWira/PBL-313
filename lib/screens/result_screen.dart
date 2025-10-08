import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  final Map<String, dynamic> perjalanan;

  const RiwayatScreen({super.key, required this.perjalanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Perjalanan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Kendaraan", perjalanan["kendaraan"]),
                _infoRow("Bahan Bakar", perjalanan["bahan_bakar"]),
                _infoRow("Durasi", perjalanan["durasi"]),
                _infoRow("Jarak Tempuh", perjalanan["jarak"]),
                _infoRow("Emisi CO₂", perjalanan["emisi"]),
                _infoRow("Waktu", perjalanan["waktu"]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    ),
  );
}