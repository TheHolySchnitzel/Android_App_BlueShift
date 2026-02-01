import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ScenesScreen extends StatelessWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Szenen'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // BlueShift Mode - Gleiche Breite wie andere
                _buildBlueShiftMode(context, bt),
                const SizedBox(height: 16),
                _buildSceneCard(
                  context,
                  bt,
                  'Entspannung',
                  Icons.spa,
                  const Color(0xFF8B5CF6),
                  Colors.purple.shade200,
                ),
                const SizedBox(height: 16),
                _buildSceneCard(
                  context,
                  bt,
                  'Konzentration',
                  Icons.lightbulb,
                  const Color(0xFF00D9FF),
                  Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlueShiftMode(BuildContext context, BluetoothService bt) {
    final isActive = bt.activeMode == "BlueShift"; // NEU: Check ob aktiv

    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D9FF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D9FF).withAlpha(120),
          width: isActive ? 2.5 : 1.5, // NEU: Dichere Border wenn aktiv
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFF00D9FF).withAlpha(102),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : [], // NEU: Glow wenn aktiv
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            bt.setMode("BlueShift");
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'BlueShift Mode',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(76),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Aktiv',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D9FF),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Intelligente Lichtsteuerung',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Bei den anderen Szenen auch setMode hinzufügen:
  Widget _buildSceneCard(BuildContext context,
      BluetoothService bt,
      String title,
      IconData icon,
      Color color,
      Color lightColor,) {
    final isActive = bt.activeMode ==
        title; // NEU: Check ob diese Szene aktiv ist

    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(76), color.withAlpha(25)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(76),
          width: isActive ? 2.5 : 1.5, // NEU: Dickere Border wenn aktiv
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: color.withAlpha(102),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            bt.setMode(title);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withAlpha(76),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Aktiv',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}