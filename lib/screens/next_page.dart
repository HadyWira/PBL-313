import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Berikutnya")),
      body: const Center(child: Text("Di sini bisa lanjut ke input data perjalanan/emisi.")),
    );
  }
}