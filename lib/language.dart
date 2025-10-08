import 'package:flutter/material.dart';

/// Simple i18n helper untuk 2 bahasa (id / en).
class AppLanguage {
  // default bahasa Indonesia
  static final ValueNotifier<String> currentLang = ValueNotifier<String>('id');

  static void setLang(String lang) => currentLang.value = lang;

  static final Map<String, Map<String, String>> _values = {
    'id': {
      // umum
      'appTitle': 'Tracking App',
      'username': 'Nama Pengguna',
      'password': 'Kata Sandi',
      'login': 'Masuk',
      'register': 'Daftar',
      'ok': 'OK',
      'continue': 'Lanjutkan',
      'choose': 'Pilih',
      'selected': 'Dipilih',
      'vehicle_selected': 'Kendaraan Dipilih',
      'you_choose': 'Anda memilih',
      'choose_vehicle': 'Pilih Kendaraan',

      // tracking screen
      'start': 'Mulai',
      'pause': 'Jeda',
      'stop': 'Berhenti',
      'duration': 'Durasi',
      'distance': 'Jarak',
      'emission': 'Emisi CO₂',
      'mode': 'Mode',
      'simulation': 'Simulasi',
      'gps': 'GPS',
      'fuel': 'Bahan Bakar',

      // pesan lokasi
      'location_disabled': 'Layanan lokasi dinonaktifkan!',
      'location_denied': 'Izin lokasi ditolak!',
      'location_permanent_denied': 'Izin lokasi ditolak permanen!',

      // kategori & kendaraan
      'car': 'Mobil (Bensin)',
      'car_small': 'Mobil CC Kecil (≤1500 cc)',
      'car_large': 'Mobil CC Besar (>2000 cc)',
      'car_diesel': 'Mobil (Solar)',
      'car_diesel_small': 'Mobil CC Kecil (≤1500 cc)',
      'car_diesel_large': 'Mobil CC Besar (>2000 cc)',
      'car_electric': 'Mobil Listrik',

      'motor': 'Motor',
      'motor_small': 'Motor CC Kecil (≤150 cc)',
      'motor_large': 'Motor CC Besar (>250 cc)',
      'motor_electric': 'Motor Listrik',

      'truck_diesel': 'Truk',

      'bus': 'Bus',
      'bus_fuel': 'Bus BBM',
      'bus_gas': 'Bus Gas',
      'bus_electric': 'Bus Listrik',

      'bike': 'Sepeda',

      // ✅ tambahan untuk ResultScreen
      'result_title': 'Hasil Perjalanan',
      'vehicle': 'Kendaraan',
      'avg_speed': 'Kecepatan Rata-rata',
      'save_history': 'Simpan ke Riwayat',
      'back_to_tracking': 'Kembali ke Tracking',
      'history_saved': 'Riwayat berhasil disimpan!',
    },
    'en': {
      // common
      'appTitle': 'Tracking App',
      'username': 'Username',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register',
      'ok': 'OK',
      'continue': 'Continue',
      'choose': 'Choose',
      'selected': 'Selected',
      'vehicle_selected': 'Vehicle Selected',
      'you_choose': 'You chose',
      'choose_vehicle': 'Choose Vehicle',

      // tracking screen
      'start': 'Start',
      'pause': 'Pause',
      'stop': 'Stop',
      'duration': 'Duration',
      'distance': 'Distance',
      'emission': 'CO₂ Emission',
      'mode': 'Mode',
      'simulation': 'Simulation',
      'gps': 'GPS',
      'fuel': 'Fuel',

      // location messages
      'location_disabled': 'Location service disabled!',
      'location_denied': 'Location permission denied!',
      'location_permanent_denied': 'Location permission permanently denied!',

      // categories & vehicles
      'car': 'Gasoline Car',
      'car_small': 'Small Gasoline Car (≤1500 cc)',
      'car_large': 'Large Gasoline Car (>2000 cc)',
      'car_diesel': 'Diesel Car',
      'car_diesel_small': 'Small Diesel Car (≤1500 cc)',
      'car_diesel_large': 'Large Diesel Car (>2000 cc)',
      'car_electric': 'Electric Car',

      'motor': 'Motorcycle',
      'motor_small': 'Small Motorcycle (≤150 cc)',
      'motor_large': 'Large Motorcycle (>250 cc)',
      'motor_electric': 'Electric Motorcycle',

      'truck_diesel': 'Truck',

      'bus': 'Bus',
      'bus_fuel': 'Fuel Bus',
      'bus_gas': 'Gas Bus',
      'bus_electric': 'Electric Bus',

      'bike': 'Bicycle',

      // ✅ tambahan untuk ResultScreen
      'result_title': 'Trip Result',
      'vehicle': 'Vehicle',
      'avg_speed': 'Average Speed',
      'save_history': 'Save to History',
      'back_to_tracking': 'Back to Tracking',
      'history_saved': 'History Saved!',
    }
  };

  static String text(String key) {
    return _values[currentLang.value]?[key] ?? key;
  }
}

class LanguageController {
  static ValueNotifier<String> get currentLang => AppLanguage.currentLang;
  static void setLang(String lang) => AppLanguage.setLang(lang);
  static String t(String key) => AppLanguage.text(key);
}