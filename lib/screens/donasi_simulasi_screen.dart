import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class DonasiSimulasiScreen extends StatefulWidget {
  final double totalEmisi;

  const DonasiSimulasiScreen({super.key, required this.totalEmisi});

  @override
  State<DonasiSimulasiScreen> createState() => _DonasiSimulasiScreenState();
}

class _DonasiSimulasiScreenState extends State<DonasiSimulasiScreen> {
  double selectedNominal = 5000;
  bool isConfirming = false;

  final double biayaPerPohon = 25000;
  final List<String> daftarKomunitas = [
    "Komunitas Pohon Mangrove",
    "Komunitas Energi Bersih",
    "Komunitas Reforestasi Gunung",
    "Komunitas Laut Bersih",
  ];
  String? selectedKomunitas;

  double get konversiRupiah => widget.totalEmisi * 2100;
  double get jumlahPohonUntukNetral =>
      widget.totalEmisi <= 0 ? 0 : (widget.totalEmisi / 21).ceilToDouble();
  double get jumlahPohonDariDonasi =>
      (selectedNominal / biayaPerPohon).clamp(0, double.infinity).ceilToDouble();

  Future<void> _simpanRiwayat(double nominal, double pohon) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Simpan ke tab offset (real data)
    await _tambahKeRiwayatOffset(now, nominal, pohon);

    double offsetSekarang = prefs.getDouble('totalOffset') ?? 0.0;
    double totalEmisiGlobal = prefs.getDouble('totalEmisiGlobal') ?? 0.0;
    double tambahanOffset = pohon * 21.0;
    double totalOffsetBaru = offsetSekarang + tambahanOffset;
    double totalEmisiBaru =
    (totalEmisiGlobal - tambahanOffset).clamp(0, double.infinity);

    await prefs.setDouble('totalOffset', totalOffsetBaru);
    await prefs.setDouble('totalEmisiGlobal', totalEmisiBaru);
  }

  Future<void> _tambahKeRiwayatOffset(
      DateTime tanggal, double nominal, double pohon) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayatOffset');
    List<Map<String, dynamic>> offsetList = [];

    if (data != null) {
      offsetList = List<Map<String, dynamic>>.from(json.decode(data));
    }

    final newOffset = {
      "id": "#SIM${Random().nextInt(99999).toString().padLeft(5, '0')}",
      "judul":
      "Donasi simulasi berhasil mengurangi ${(pohon * 21).toStringAsFixed(0)} kg CO₂",
      "tanggal": tanggal.toIso8601String(),
      "nominal": nominal,
      "emisi": (pohon * 21).toStringAsFixed(0),
      "status": "Simulasi berhasil",
      "komunitas": selectedKomunitas ?? "Tidak dipilih",
      "metode": "Simulasi (tidak nyata)",
    };

    offsetList.add(newOffset);
    await prefs.setString('riwayatOffset', json.encode(offsetList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F1),
      appBar: AppBar(
        title: Text("Simulasi Donasi Hijau",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF8F1), Color(0xFFD7F5D5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmisiCard(),
                  const SizedBox(height: 30),
                  _buildNominalPilihan(),
                  const SizedBox(height: 30),
                  _buildPilihKomunitas(),
                  const SizedBox(height: 30),
                  _buildCatatanSimulasi(),
                  const SizedBox(height: 40),
                  _buildTombolDonasi(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌿 Dropdown pilih komunitas
  Widget _buildPilihKomunitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pilih komunitas untuk mendukung:",
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3))
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedKomunitas,
              hint: Text("Pilih komunitas",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600)),
              isExpanded: true,
              items: daftarKomunitas.map((komunitas) {
                return DropdownMenuItem(
                  value: komunitas,
                  child: Text(komunitas, style: GoogleFonts.poppins(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKomunitas = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // 🧩 Kartu Emisi
  Widget _buildEmisiCard() {
    double progress =
    (jumlahPohonDariDonasi / jumlahPohonUntukNetral).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.eco, color: Colors.green, size: 40),
          const SizedBox(height: 8),
          Text(
            "Total Emisi Karbonmu",
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            "${widget.totalEmisi.toStringAsFixed(2)} kg CO₂",
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "≈ Rp${konversiRupiah.toStringAsFixed(0)} untuk di-offset",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF5E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Butuh ${jumlahPohonUntukNetral.toStringAsFixed(0)} pohon 🌳 untuk netral",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            "Kontribusi donasi ini ${(progress * 100).toStringAsFixed(1)}% menuju netral 🌏",
            style:
            GoogleFonts.poppins(fontSize: 12.5, color: Colors.green.shade800),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 💰 Pilihan nominal
  Widget _buildNominalPilihan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pilih nominal simulasi donasi:",
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _nominalChip(5000),
            _nominalChip(10000),
            _nominalChip(20000),
            _nominalChip(50000),
            _nominalChip(100000),
          ],
        ),
      ],
    );
  }

  Widget _nominalChip(double nominal) {
    final bool isSelected = selectedNominal == nominal;
    return ChoiceChip(
      label: Text("Rp${nominal.toStringAsFixed(0)}"),
      selected: isSelected,
      onSelected: (_) => setState(() => selectedNominal = nominal),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4CAF50),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13.5,
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
    );
  }

  // 🧾 Catatan edukatif
  Widget _buildCatatanSimulasi() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Simulasi ini hanya edukatif dan tidak memproses pembayaran nyata.",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // 🌱 Tombol Konfirmasi
  Widget _buildTombolDonasi(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.volunteer_activism_outlined, color: Colors.white),
        label: Text(
          "Konfirmasi Simulasi",
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.green.withOpacity(0.4),
          elevation: 8,
        ),
        onPressed: selectedKomunitas == null
            ? null
            : () => _showKonfirmasiPopup(context),
      ),
    );
  }

  // 🌿 Popup konfirmasi
  void _showKonfirmasiPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco, color: Colors.green, size: 60),
              const SizedBox(height: 10),
              Text("Konfirmasi Donasi",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Komunitas: ${selectedKomunitas ?? '-'}",
                  style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              Text("Total: Rp${selectedNominal.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.teal,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                "Setara ${jumlahPohonDariDonasi.toStringAsFixed(0)} pohon 🌳",
                style: GoogleFonts.poppins(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => isConfirming = true);
                        await Future.delayed(const Duration(seconds: 1));
                        await _simpanRiwayat(
                            selectedNominal, jumlahPohonDariDonasi);
                        if (mounted) {
                          Navigator.pop(context);
                          _showSuccessDialog(context);
                          setState(() => isConfirming = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Konfirmasi"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Dialog sukses tanpa overflow
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        backgroundColor: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text("Simulasi Berhasil",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ],
        ),
        content: Text(
          "Donasi Rp${selectedNominal.toStringAsFixed(0)} untuk ${selectedKomunitas ?? '-'} berhasil disimpan 🌿\nSetara ${jumlahPohonDariDonasi.toStringAsFixed(0)} pohon baru ditanam!",
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}