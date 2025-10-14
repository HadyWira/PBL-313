import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final Color softGreen = const Color(0xFFFFFFFF);
  final Color mintGreen = const Color(0xFFFFFFFF);
  final Color tealColor = const Color(0xFF3E5F44);
  final Color darkText = const Color(0xFF2E3A3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 Background Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [softGreen, Colors.white, mintGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌤️ Lapisan awan SVG (background lembut)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/awan.svg',
              fit: BoxFit.cover,
            ),
          ),

          // 🏔️ Lengkungan SVG dinamis
          if (currentPage == "welcome")
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 60), // nilai positif = turun
              child: SvgPicture.asset(
                'assets/vector.svg',
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
              ),
            ),
          )

          else
            Align(
              alignment: Alignment.topCenter,
              child: SvgPicture.asset(
                'assets/vector.svg',
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.32, // 🔹 lebih halus
              ),
            ),

          // 🌿 Konten halaman
          AnimatedSwitcher(
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
        ],
      ),
    );
  }

  Widget _buildPage(String page) {
    switch (page) {
      case "welcome":
        return _welcomePage();
      case "login":
        return _pageWithFooter(_loginPage());
      case "register":
        return _pageWithFooter(_registerPage());
      case "verify":
        return _pageWithFooter(_verifyPage());
      case "forgot":
        return _pageWithFooter(_forgotPasswordPage());
      default:
        return _welcomePage();
    }
  }

  // 🌿 Wrapper halaman dengan footer
  Widget _pageWithFooter(Widget content) {
    return Column(
      children: [
        Expanded(child: content),
        Container(
          height: 70,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Center(
            child: Text(
              "EcoTrack   PBL-313",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🌿 Welcome Page
  Widget _welcomePage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 90),

            // 🪴 Logo di bagian atas tengah
            Image.asset(
              'assets/logo.png',
              height: 110,
            ),

            const SizedBox(height: 25),
            Text(
              "Hitung Jejakmu, Hijaukan Bumi",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Catat emisi kendaraanmu, donasikan kebaikanmu",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 50),
            _animatedButton("Masuk", () => switchPage("login")),
            const SizedBox(height: 14),
            _outlinedButton("Registrasi", () => switchPage("register")),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // 🌿 Login Page
  Widget _loginPage() {
    return _pageWrapper(
      title: "Masuk",
      subtitle: "Silahkan isi data anda sebelum masuk",
      showTopImage: true,
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
          child: const Text("Lupa kata sandi?",
              style: TextStyle(color: Colors.black54)),
        ),
        TextButton(
          onPressed: () => switchPage("register"),
          child: const Text("Belum punya akun? Daftar",
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  // 🌿 Register Page
  Widget _registerPage() {
    return _pageWrapper(
      title: "Daftar",
      subtitle: "Silahkan isi data anda untuk mendaftar.",
      showTopImage: true,
      children: [
        _inputField("Nama Lengkap", icon: Icons.person_outline),
        const SizedBox(height: 12),
        _inputField("Email", icon: Icons.email_outlined),
        const SizedBox(height: 12),
        _inputField("Password", icon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 12),
        _inputField("Konfirmasi Password",
            icon: Icons.lock_reset, obscure: true),
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

  // 🌿 Verify Page
  Widget _verifyPage() {
    return _pageWrapper(
      title: "Verifikasi Akun Anda",
      subtitle: "Masukkan kode yang dikirim ke email Anda.",
      showTopImage: true,
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
          child: const Text("Sudah terverifikasi? Masuk",
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  // 🌿 Forgot Password Page
  Widget _forgotPasswordPage() {
    return _pageWrapper(
      title: "Lupa Kata Sandi",
      subtitle: "Masukkan email Anda untuk reset password.",
      showTopImage: true,
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

  // 🌿 Wrapper konten
  Widget _pageWrapper({
    required String title,
    String? subtitle,
    required List<Widget> children,
    bool showTopImage = false,
  }) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTopImage) ...[
                const SizedBox(height: 50),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🌿 Input Field
  Widget _inputField(String label, {bool obscure = false, IconData? icon}) {
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
          borderSide: const BorderSide(color: Colors.teal, width: 1.8),
        ),
      ),
    );
  }

  // 🌿 Tombol utama
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

  // 🌿 Tombol outline
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
