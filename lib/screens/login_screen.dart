import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String currentPage = "welcome";
  bool isLoading = false;

  void switchPage(String page) {
    setState(() {
      currentPage = page;
    });
  }

  final Color softGreen = const Color(0xFFE6F4EA);
  final Color mintGreen = const Color(0xFFBFE3C0);
  final Color tealColor = const Color(0xFF5DBB63);
  final Color darkText = const Color(0xFF2E3A3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [softGreen, Colors.white, mintGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _buildPage(currentPage),
        ),
      ),
    );
  }

  Widget _buildPage(String page) {
    switch (page) {
      case "welcome":
        return _welcomePage();
      case "login":
        return _loginPage();
      case "register":
        return _registerPage();
      case "verify":
        return _verifyPage();
      case "forgot":
        return _forgotPasswordPage();
      default:
        return _welcomePage();
    }
  }

  // 🌱 1. Welcome Page
  Widget _welcomePage() {
    return _pageWrapper(
      title: "Selamat Datang 🌿",
      subtitle: "Jejak hijau dimulai dari sini.",
      children: [
        _animatedButton("Masuk", () => switchPage("login")),
        const SizedBox(height: 14),
        _outlinedButton("Buat Akun Baru", () => switchPage("register")),
      ],
    );
  }

  // 🌿 2. Login Page
  Widget _loginPage() {
    return _pageWrapper(
      title: "Masuk Akun",
      subtitle: "Masuk untuk melanjutkan perjalanan hijau Anda.",
      children: [
        _inputField("Email", icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _inputField("Password", icon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 28),
        _animatedButton("Masuk", () async {
          setState(() => isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          setState(() => isLoading = false);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => switchPage("forgot"),
          child: const Text("Lupa kata sandi?", style: TextStyle(color: Colors.black54)),
        ),
        TextButton(
          onPressed: () => switchPage("register"),
          child: const Text("Belum punya akun? Daftar",
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  // 🌿 3. Register Page
  Widget _registerPage() {
    return _pageWrapper(
      title: "Buat Akun Baru",
      subtitle: "Mulai langkah hijau Anda bersama kami.",
      children: [
        _inputField("Nama Lengkap", icon: Icons.person_outline),
        const SizedBox(height: 12),
        _inputField("Email", icon: Icons.email_outlined),
        const SizedBox(height: 12),
        _inputField("Password", icon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 12),
        _inputField("Konfirmasi Password", icon: Icons.lock_reset, obscure: true),
        const SizedBox(height: 28),
        _animatedButton("Daftar", () => switchPage("verify")),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => switchPage("login"),
          child: const Text("Sudah punya akun? Masuk",
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  // 🌿 4. Verify Account Page
  Widget _verifyPage() {
    return _pageWrapper(
      title: "Verifikasi Akun Anda",
      subtitle: "Masukkan kode yang dikirim ke email Anda.",
      children: [
        _inputField("Kode Verifikasi", icon: Icons.verified_outlined),
        const SizedBox(height: 24),
        _animatedButton("Verifikasi", () async {
          setState(() => isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          setState(() => isLoading = false);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => switchPage("login"),
          child: const Text(
            "Sudah terverifikasi? Masuk",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // 🌿 5. Forgot Password Page
  Widget _forgotPasswordPage() {
    return _pageWrapper(
      title: "Lupa Kata Sandi",
      subtitle: "Masukkan email Anda untuk reset password.",
      children: [
        _inputField("Email", icon: Icons.email_outlined),
        const SizedBox(height: 24),
        _animatedButton("Kirim", () => switchPage("login")),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => switchPage("login"),
          child: const Text("Kembali ke Login",
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  // ✨ Wrapper untuk setiap halaman
  Widget _pageWrapper({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              const Icon(Icons.eco, size: 90, color: Color(0xFF5DBB63)),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 Input Field
  Widget _inputField(String label,
      {bool obscure = false, IconData? icon}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.teal, width: 1.8),
        ),
      ),
    );
  }

  // 🌿 Primary Button
  Widget _animatedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: tealColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 🌿 Outlined Button
  Widget _outlinedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: tealColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: tealColor,
          ),
        ),
      ),
    );
  }
}