import 'package:flutter/material.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raumsteuerung'),
        backgroundColor: const Color(0xFF191E29),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF191E29), Color(0xFF0A0E21)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view, size: 80, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                'Raumteilung',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kommt bald!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}