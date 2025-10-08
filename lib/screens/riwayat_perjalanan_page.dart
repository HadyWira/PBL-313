import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPerjalananPage extends StatefulWidget {
  const RiwayatPerjalananPage({super.key});

  @override
  State<RiwayatPerjalananPage> createState() => _RiwayatPerjalananPageState();
}

class _RiwayatPerjalananPageState extends State<RiwayatPerjalananPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allTrips = [];
  List<Map<String, dynamic>> _offsetList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTrips();
    _loadOffsetReal(); // ✅ Ambil offset simulasi real
  }

  // ===========================================================
  // 🚗 Fungsi memuat data perjalanan
  // ===========================================================
  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final trips = prefs.getStringList('trip_history') ?? [];
    setState(() {
      _allTrips =
          trips.map((t) => Map<String, dynamic>.from(jsonDecode(t))).toList();
      _allTrips.sort((a, b) {
        final da = DateTime.parse(a['date'].toString());
        final db = DateTime.parse(b['date'].toString());
        return db.compareTo(da);
      });
    });
  }

  // ===========================================================
  // 🌿 Fungsi memuat data offset simulasi (dari Donasi Offset Page)
  // ===========================================================
  Future<void> _loadOffsetReal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayatOffset');
    if (data != null) {
      setState(() {
        _offsetList = List<Map<String, dynamic>>.from(jsonDecode(data));
        _offsetList.sort((a, b) {
          final da = DateTime.parse(a['tanggal']);
          final db = DateTime.parse(b['tanggal']);
          return db.compareTo(da);
        });
      });
    }
  }

  // ===========================================================
  // 🗑️ Hapus data offset simulasi
  // ===========================================================
  Future<void> _deleteOffsetByDate(String tanggalIso) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayatOffset');
    if (data == null) return;

    final decoded = List<Map<String, dynamic>>.from(jsonDecode(data));
    final index = decoded.indexWhere((e) => e['tanggal'] == tanggalIso);
    if (index != -1) {
      decoded.removeAt(index);
      await prefs.setString('riwayatOffset', jsonEncode(decoded));
      await _loadOffsetReal();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Riwayat offset berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ===========================================================
  // 🗑️ Hapus data perjalanan
  // ===========================================================
  Future<void> _deleteTripByDate(String dateIso) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = prefs.getStringList('trip_history') ?? [];

    final decoded =
    trips.map((t) => Map<String, dynamic>.from(jsonDecode(t))).toList();
    final idx = decoded.indexWhere((t) => t['date'].toString() == dateIso);
    if (idx != -1) {
      trips.removeAt(idx);
      await prefs.setStringList('trip_history', trips);
      await _loadTrips();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Riwayat perjalanan berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatNumber(dynamic value) {
    double v = 0;
    if (value is num) {
      v = value.toDouble();
    } else {
      v = double.tryParse(value?.toString() ?? "0") ?? 0.0;
    }
    return v.toStringAsFixed(2);
  }

  IconData _getVehicleIcon(String vehicle) {
    switch (vehicle.toLowerCase()) {
      case "car":
      case "mobil":
        return Icons.directions_car;
      case "motor":
      case "motorbike":
        return Icons.two_wheeler;
      case "bus":
        return Icons.directions_bus;
      case "bicycle":
      case "sepeda":
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  // ===========================================================
  // 🧾 Kartu perjalanan
  // ===========================================================
  Widget _buildTripCard(Map<String, dynamic> trip) {
    final date = DateTime.parse(trip['date'].toString());
    final emissionFormatted = _formatNumber(trip['emission']);
    final distanceFormatted = _formatNumber(trip['distance']);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailRiwayatPage(trip: trip),
          ),
        );
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(_getVehicleIcon(trip['vehicle'].toString()),
                  color: Colors.white, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🌍 Emisi CO₂: $emissionFormatted kg",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      "⏱️ ${trip['duration']}  |  📏 $distanceFormatted km",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "🚗 ${trip['vehicle']} - ${trip['fuelType']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text("${date.day}-${date.month}-${date.year}",
                      style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteTripByDate(trip['date'].toString()),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // 🌳 Kartu Offset (REAL dari simulasi)
  // ===========================================================
  Widget _buildOffsetCard(Map<String, dynamic> offset) {
    final date = DateTime.parse(offset['tanggal'].toString());
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.eco, color: Colors.green, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offset['judul'] ?? "Simulasi Offset",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Emisi: ${offset['emisi']} kg CO₂",
                      style: const TextStyle(color: Colors.black87)),
                  Text("Donasi: Rp ${offset['nominal']}",
                      style: const TextStyle(color: Colors.black87)),
                  Text("Metode: ${offset['metode']}",
                      style: const TextStyle(color: Colors.black54)),
                  Text("Status: ${offset['status']}",
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${date.day}-${date.month}-${date.year}",
                    style:
                    const TextStyle(color: Colors.black54, fontSize: 12)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _deleteOffsetByDate(offset['tanggal'].toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // 📊 Group harian & mingguan
  // ===========================================================
  List<Map<String, dynamic>> _groupByDay(List<Map<String, dynamic>> trips) {
    final Map<String, double> grouped = {};
    for (var trip in trips) {
      final date = DateTime.parse(trip['date'].toString());
      final key = "${date.year}-${date.month}-${date.day}";
      grouped[key] = (grouped[key] ?? 0) + (trip['emission'] as num).toDouble();
    }
    return grouped.entries
        .map((e) => {"date": e.key, "emission": e.value})
        .toList();
  }

  List<Map<String, dynamic>> _groupByWeek(List<Map<String, dynamic>> trips) {
    final Map<String, double> grouped = {};
    for (var trip in trips) {
      final date = DateTime.parse(trip['date'].toString());
      final week = "${date.year}-W${((date.day - 1) ~/ 7) + 1}";
      grouped[week] =
          (grouped[week] ?? 0) + (trip['emission'] as num).toDouble();
    }
    return grouped.entries
        .map((e) => {"week": e.key, "emission": e.value})
        .toList();
  }

  // ===========================================================
  // 🧭 UI Utama
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final groupedDaily = _groupByDay(_allTrips);
    final groupedWeekly = _groupByWeek(_allTrips);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Perjalanan"),
          backgroundColor: const Color(0xFF56AB2F),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Harian"),
              Tab(text: "Mingguan"),
              Tab(text: "Bulanan"),
              Tab(text: "Offset"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_allTrips),
            _buildSummaryList(groupedDaily, isDaily: true),
            _buildSummaryList(groupedWeekly, isDaily: false),
            _buildOffsetList(), // ✅ Real offset tab
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // 📋 Daftar Perjalanan
  // ===========================================================
  Widget _buildList(List<Map<String, dynamic>> trips) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: trips.isEmpty
          ? const Center(
          child: Text("🌱 Belum ada riwayat perjalanan",
              style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 110, top: 12),
        itemCount: trips.length,
        itemBuilder: (c, i) => _buildTripCard(trips[i]),
      ),
    );
  }

  // ===========================================================
  // 🌿 Daftar Offset (REAL dari SharedPreferences)
  // ===========================================================
  Widget _buildOffsetList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _offsetList.isEmpty
          ? const Center(
          child: Text("🌱 Belum ada data offset simulasi",
              style: TextStyle(color: Colors.grey, fontSize: 16)))
          : RefreshIndicator(
        onRefresh: _loadOffsetReal,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 110, top: 12),
          itemCount: _offsetList.length,
          itemBuilder: (c, i) => _buildOffsetCard(_offsetList[i]),
        ),
      ),
    );
  }

  // ===========================================================
  // 📆 List Harian / Mingguan
  // ===========================================================
  Widget _buildSummaryList(List<Map<String, dynamic>> data,
      {required bool isDaily}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: data.isEmpty
          ? const Center(
          child: Text("🌱 Belum ada data",
              style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 110, top: 12),
        itemCount: data.length,
        itemBuilder: (c, i) {
          final item = data[i];
          return Card(
            elevation: 4,
            margin:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco,
                      color: Colors.green.shade800, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDaily
                          ? "Tanggal: ${item['date']} | Total Emisi: ${_formatNumber(item['emission'])} kg"
                          : "Minggu: ${item['week']} | Total Emisi: ${_formatNumber(item['emission'])} kg",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========== DETAIL RIWAYAT ========== (tidak diubah)
class DetailRiwayatPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  const DetailRiwayatPage({super.key, required this.trip});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  List<LatLng> route = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isReplaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip['route'] != null) {
      final List<dynamic> points = widget.trip['route'];
      route = points
          .map((p) =>
          LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
          .toList();
    }
  }

  void _startReplay() {
    if (route.isEmpty) return;
    setState(() {
      _currentIndex = 0;
      _isReplaying = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentIndex < route.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _timer?.cancel();
        setState(() => _isReplaying = false);
      }
    });
  }

  void _stopReplay() {
    _timer?.cancel();
    setState(() => _isReplaying = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatNumber(dynamic value) {
    double v = value is num
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0.0;
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.trip['date'].toString());
    final defaultCenter = LatLng(1.0456, 104.0305);
    final emissionFormatted = _formatNumber(widget.trip['emission']);
    final distanceFormatted = _formatNumber(widget.trip['distance']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Riwayat"),
        backgroundColor: const Color(0xFF56AB2F),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: route.isNotEmpty ? route.first : defaultCenter,
              initialZoom: 14,
              interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: route, strokeWidth: 5, color: Colors.blueAccent),
                  ],
                ),
              if (route.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                        point: route.first,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag,
                            color: Colors.green, size: 32)),
                    Marker(
                        point: route.last,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 36)),
                    if (_isReplaying)
                      Marker(
                          point: route[_currentIndex],
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.directions_car,
                              size: 40, color: Colors.orange)),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.directions_car, color: Colors.white, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${date.day}-${date.month}-${date.year}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("🌍 Emisi CO₂ : $emissionFormatted kg",
                            style: const TextStyle(color: Colors.white)),
                        Text("⏱️ Waktu : ${widget.trip['duration']}",
                            style: const TextStyle(color: Colors.white)),
                        Text("📏 Jarak : $distanceFormatted km",
                            style: const TextStyle(color: Colors.white)),
                        Text("🚗 Kendaraan : ${widget.trip['vehicle']} (${widget.trip['fuelType']})",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton.icon(
              onPressed: _isReplaying ? _stopReplay : _startReplay,
              icon: Icon(_isReplaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isReplaying ? "Stop Replay" : "Replay Perjalanan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}