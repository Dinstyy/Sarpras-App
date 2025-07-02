import 'package:flutter/material.dart';

class Caraka extends StatelessWidget {
  const Caraka({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Caraka')),
      body: Center(
        child: Text('Selamat datang Caraka', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
