// tracking_screen.dart
// ================== TRACKING & RESULT SCREEN ==================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// import halaman lain
import 'login_screen.dart';
import 'riwayat_perjalanan_page.dart';
import 'home_screen.dart';

// ================== HELPER FORMAT ANGKA ==================
String formatNumber(dynamic value) {
  double v = 0;
  if (value is num) {
    v = value.toDouble();
  } else {
    v = double.tryParse(value?.toString() ?? "0") ?? 0.0;
  }
  return v.toStringAsFixed(2);
}

// ================== TRACKING SCREEN ==================
class TrackingScreen extends StatefulWidget {
  final String vehicle;
  final String fuelType;

  const TrackingScreen({
    super.key,
    required this.vehicle,
    required this.fuelType,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  LatLng currentPos = LatLng(1.0821, 104.0305);

  bool _tracking = false;
  bool _paused = false;
  bool _isSimulation = false;
  String _mapStyle = "Normal";

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double distanceTravelled = 0;
  double emission = 0;
  late double _emissionFactor;

  String _elapsed = "00:00:00";
  final List<LatLng> _route = [];
  final List<Map<String, dynamic>> _routePoints = [];

  StreamSubscription<Position>? _gpsStream;
  Position? _lastPosition;

  // hasil akhir
  String? _finalDuration;
  double? _finalDistance;
  double? _finalEmission;
  List<LatLng>? _finalRoute;
  List<Map<String, dynamic>>? _finalRouteWithTime;

  double getEmissionFactor(String vehicle, String fuelType) {
    vehicle = vehicle.toLowerCase();
    fuelType = fuelType.toLowerCase();

    if (vehicle.contains("motor")) {
      if (fuelType.contains("bensin")) return 0.082;
      if (fuelType.contains("listrik")) return 0.020;
    } else if (vehicle.contains("mobil")) {
      if (fuelType.contains("bensin")) return 0.192;
      if (fuelType.contains("solar")) return 0.250;
      if (fuelType.contains("listrik")) return 0.050;
    } else if (vehicle.contains("bus")) {
      if (fuelType.contains("solar")) return 0.822;
      if (fuelType.contains("gas")) return 0.650;
      if (fuelType.contains("listrik")) return 0.050;
    } else if (vehicle.contains("truk")) {
      return 1.050;
    } else if (vehicle.contains("sepeda")) {
      return 0.0;
    }
    return 0.200;
  }

  @override
  void initState() {
    super.initState();
    _emissionFactor = getEmissionFactor(widget.vehicle, widget.fuelType);
  }

  void _pauseTracking() {
    if (!_tracking) return;
    setState(() {
      _paused = true;
      _tracking = false;
    });
    _stopwatch.stop();
    _gpsStream?.pause();
    _timer?.cancel();
    _showSnackBar("⏸ Tracking dijeda.");
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("⚠️ Layanan lokasi tidak aktif!");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("❌ Izin lokasi ditolak!");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("❌ Izin lokasi ditolak permanen!");
      return;
    }

    Position pos =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPos = LatLng(pos.latitude, pos.longitude);
      _lastPosition = pos;
      _mapController.move(currentPos, 16);
    });
  }

  void _startTracking() async {
    await _getCurrentLocation();

    if (!_paused) {
      _route.clear();
      _routePoints.clear();
      distanceTravelled = 0;
      emission = 0;
      _stopwatch.reset();
    }

    setState(() {
      _tracking = true;
      _paused = false;
      if (!_stopwatch.isRunning) _stopwatch.start();
      _elapsed = _formatDuration(_stopwatch.elapsed);
    });

    if (!_isSimulation) {
      _gpsStream ??= Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
        ),
      ).listen((pos) {
        if (_tracking) {
          if (_lastPosition != null) {
            final double moved = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              pos.latitude,
              pos.longitude,
            );
            if (moved >= 0.5) {
              setState(() {
                currentPos = LatLng(pos.latitude, pos.longitude);
                _route.add(currentPos);
                _routePoints.add({
                  'lat': pos.latitude,
                  'lng': pos.longitude,
                  'time': DateTime.now().toIso8601String(),
                });
                final double segment = moved / 1000;
                distanceTravelled += segment;
                emission = distanceTravelled * _emissionFactor;
                _lastPosition = pos;
                _mapController.move(currentPos, _mapController.camera.zoom);
              });
            }
          } else {
            _lastPosition = pos;
            setState(() {
              currentPos = LatLng(pos.latitude, pos.longitude);
              _route.add(currentPos);
              _routePoints.add({
                'lat': pos.latitude,
                'lng': pos.longitude,
                'time': DateTime.now().toIso8601String(),
              });
              _mapController.move(currentPos, _mapController.camera.zoom);
            });
          }
        }
      });
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_tracking) return;
      setState(() {
        if (_isSimulation) {
          currentPos = LatLng(
            currentPos.latitude + 0.0001,
            currentPos.longitude + 0.0001,
          );
          _route.add(currentPos);
          _routePoints.add({
            'lat': currentPos.latitude,
            'lng': currentPos.longitude,
            'time': DateTime.now().toIso8601String(),
          });
          distanceTravelled += 0.015;
          emission = distanceTravelled * _emissionFactor;
          _mapController.move(currentPos, _mapController.camera.zoom);
        }
        _elapsed = _formatDuration(_stopwatch.elapsed);
      });
    });

    _showSnackBar(_paused ? "▶️ Lanjut tracking." : "🚀 Tracking dimulai!");
  }

  // ✅ Disini aku tambahkan update global untuk sinkron HomeScreen
  Future<void> _saveTripHistory({
    required double emission,
    required String duration,
    required double distance,
    required String vehicle,
    required String fuelType,
    required List<Map<String, dynamic>> routeWithTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> trips = prefs.getStringList('trip_history') ?? [];

    final newTrip = {
      'vehicle': vehicle,
      'fuelType': fuelType,
      'emission': emission,
      'duration': duration,
      'distance': distance,
      'date': DateTime.now().toIso8601String(),
      'route': routeWithTime,
    };

    trips.add(jsonEncode(newTrip));
    await prefs.setStringList('trip_history', trips);

    double unoffset = prefs.getDouble("unoffset_emission") ?? 0.0;
    prefs.setDouble("unoffset_emission", unoffset + emission);

    double total = prefs.getDouble("total_emission") ?? 0.0;
    prefs.setDouble("total_emission", total + emission);

    // 🟢 tambahan agar dashboard langsung sinkron
    double totalEmisiGlobal = prefs.getDouble("totalEmisiGlobal") ?? 0.0;
    prefs.setDouble("totalEmisiGlobal", totalEmisiGlobal + emission);
  }

  void _stopTracking() async {
    _timer?.cancel();
    _gpsStream?.cancel();
    _stopwatch.stop();

    setState(() {
      _tracking = false;
      _paused = false;
      _finalDuration = _formatDuration(_stopwatch.elapsed);
      _finalDistance = distanceTravelled;
      _finalEmission = emission;
      _finalRoute = List<LatLng>.from(_route);
      _finalRouteWithTime = List<Map<String, dynamic>>.from(_routePoints);
    });

    await _saveTripHistory(
      emission: _finalEmission ?? 0.0,
      duration: _finalDuration ?? "00:00:00",
      distance: _finalDistance ?? 0.0,
      vehicle: widget.vehicle,
      fuelType: widget.fuelType,
      routeWithTime: _finalRouteWithTime ?? [],
    );

    // 🟢 ubah jadi pop ke HomeScreen agar bisa refresh otomatis
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          vehicle: widget.vehicle,
          fuelType: widget.fuelType,
          duration: _finalDuration ?? "00:00:00",
          distance: _finalDistance ?? 0.0,
          emission: _finalEmission ?? 0.0,
          route: _finalRoute ?? [],
        ),
      ),
    ).then((_) {
      Navigator.pop(context, true); // ✅ kirim sinyal refresh ke HomeScreen
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }

  List<Widget> _buildMapLayers() {
    if (_mapStyle == "Normal") {
      return [
        TileLayer(
          urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
          userAgentPackageName: 'com.example.emissiontracker',
        ),
      ];
    } else if (_mapStyle == "Satelit") {
      return [
        TileLayer(
          urlTemplate: "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
          userAgentPackageName: 'com.example.emissiontracker',
        ),
      ];
    } else {
      return [
        TileLayer(
          urlTemplate: "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
          userAgentPackageName: 'com.example.emissiontracker',
        ),
      ];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gpsStream?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _mapStyle = val),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: "Normal", child: Text("Normal")),
              PopupMenuItem(value: "Satelit", child: Text("Satelit")),
              PopupMenuItem(value: "Hybrid", child: Text("Hybrid")),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentPos,
                initialZoom: 16,
              ),
              children: [
                ..._buildMapLayers(),
                PolylineLayer(
                  polylines: [
                    Polyline(points: _route, strokeWidth: 4, color: Colors.blue)
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPos,
                      width: 35,
                      height: 35,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 35),
                    ),
                  ],
                ),
              ],
            ),

            // ✅ Panel bawah (perbaikan overflow)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 240),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6)
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRow("🚗 Kendaraan", widget.vehicle),
                      _buildRow("⛽ Bahan Bakar", widget.fuelType),
                      _buildRow("⏱️ Durasi", _elapsed),
                      _buildRow("📏 Jarak",
                          "${formatNumber(distanceTravelled)} km"),
                      _buildRow(
                          "🌍 Emisi CO₂", "${formatNumber(emission)} kg"),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Mode: "),
                          Switch(
                            value: _isSimulation,
                            onChanged: (val) =>
                                setState(() => _isSimulation = val),
                          ),
                          Text(_isSimulation ? "Simulasi" : "GPS"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _tracking ? null : _startTracking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              _tracking ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(70, 32),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: Text(_paused ? "Resume" : "Start",
                                style: const TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: _tracking ? _pauseTracking : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              _tracking ? Colors.orange : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(70, 32),
                            ),
                            icon: const Icon(Icons.pause, size: 16),
                            label: const Text("Pause",
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed:
                            (_tracking || _paused) ? _stopTracking : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_tracking || _paused)
                                  ? Colors.red
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(70, 32),
                            ),
                            icon:
                            const Icon(Icons.stop, size: 16),
                            label: const Text("Stop",
                                style: TextStyle(fontSize: 12)),
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
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ================= RESULT SCREEN =================
class ResultScreen extends StatefulWidget {
  final String vehicle;
  final String fuelType;
  final String duration;
  final double distance;
  final double emission;
  final List<LatLng> route;

  const ResultScreen({
    super.key,
    required this.vehicle,
    required this.fuelType,
    required this.duration,
    required this.distance,
    required this.emission,
    required this.route,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _selectedIndex = 0;

  double _calculateAverageSpeed() {
    final parts = widget.duration.split(":");
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    final totalHours = hours + (minutes / 60) + (seconds / 3600);

    if (totalHours <= 0) return 0.0;
    return widget.distance / totalHours;
  }

  Future<void> _saveHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final historyItem = {
      "vehicle": widget.vehicle,
      "fuelType": widget.fuelType,
      "duration": widget.duration,
      "distance": widget.distance,
      "emission": widget.emission,
      "date": DateTime.now().toString().split(".").first,
    };

    final historyList = prefs.getStringList("travel_history") ?? [];
    historyList.add(jsonEncode(historyItem));
    await prefs.setStringList("travel_history", historyList);

    // update emisi
    double unoffset = prefs.getDouble("unoffset_emission") ?? 0.0;
    prefs.setDouble("unoffset_emission", unoffset + widget.emission);

    double total = prefs.getDouble("total_emission") ?? 0.0;
    prefs.setDouble("total_emission", total + widget.emission);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Riwayat berhasil disimpan!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final averageSpeed = _calculateAverageSpeed();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text("Hasil Perjalanan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRow("🚗 Kendaraan", widget.vehicle),
                  _buildRow("⛽ Bahan Bakar", widget.fuelType),
                  _buildRow("⏱️ Durasi", widget.duration),
                  _buildRow("📏 Jarak", "${widget.distance.toStringAsFixed(2)} km"),
                  _buildRow("🌍 Emisi CO₂", "${widget.emission.toStringAsFixed(2)} kg"),
                  _buildRow("⚡ Kecepatan Rata-rata",
                      "${averageSpeed.toStringAsFixed(2)} km/jam"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Rute Perjalanan",
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                  widget.route.isNotEmpty ? widget.route.first : LatLng(0, 0),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.route,
                        strokeWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (widget.route.isNotEmpty)
                        Marker(
                          point: widget.route.first,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.green, size: 40),
                        ),
                      if (widget.route.isNotEmpty)
                        Marker(
                          point: widget.route.last,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _saveHistory(context),
            icon: const Icon(Icons.save),
            label: const Text("Simpan Riwayat"),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RiwayatPerjalananPage(),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}