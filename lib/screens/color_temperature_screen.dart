import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/bluetooth_service.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  // Farbtemperatur in Kelvin (z.B. 2700K–6500K)
  double _temp = 4000;

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Farbtemperatur'),
            backgroundColor: const Color(0xFF191E29),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF191E29), Color(0xFF0A0E21)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Vorschau
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: _colorFromTemp(_temp),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _colorFromTemp(_temp).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Farbtemperatur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_temp.toInt()} K',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00D9FF),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFF00D9FF),
                      overlayColor: const Color(0xFF00D9FF).withOpacity(0.2),
                    ),
                    child: Slider(
                      min: 2700,
                      max: 6500,
                      divisions: 38,
                      value: _temp,
                      onChanged: (value) {
                        setState(() => _temp = value);
                      },
                      onChangeEnd: (value) {
                        // An ESP senden – wir kodieren Kelvin als int
                        bt.setColorTemperature(value.toInt());
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Warmweiß', style: TextStyle(color: Colors.white70)),
                      Text('Neutral', style: TextStyle(color: Colors.white70)),
                      Text('Kaltweiß', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      bt.setColorTemperature(_temp.toInt());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Farbtemperatur anwenden',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Simple Approx: Map Kelvin-Bereich auf eine Mischfarbe für die Vorschau
  Color _colorFromTemp(double k) {
    final t = ((k - 2700) / (6500 - 2700)).clamp(0.0, 1.0);
    // warm (leicht orange) bis kalt (leicht blau)
    return Color.lerp(
      const Color(0xFFFFD7A0), // warm
      const Color(0xFFCCE5FF), // kalt
      t,
    )!;
  }
}
