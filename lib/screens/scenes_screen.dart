import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bluetooth_service.dart';

class ScenesScreen extends StatelessWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        final scenes = [
          {'name': 'Entspannung', 'icon': Icons.spa, 'color': const Color(0xFF8B5CF6)},
          {'name': 'Konzentration', 'icon': Icons.psychology, 'color': const Color(0xFF00D9FF)},
          {'name': 'Party', 'icon': Icons.celebration, 'color': const Color(0xFFFF6B9D)},
          {'name': 'Lesen', 'icon': Icons.menu_book, 'color': const Color(0xFFFBBC05)},
          {'name': 'Gaming', 'icon': Icons.sports_esports, 'color': const Color(0xFF10B981)},
        ];

        return Scaffold(
          appBar: AppBar(title: const Text('Szenen'), backgroundColor: const Color(0xFF191E29)),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF191E29), Color(0xFF0A0E21)]),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: scenes.length,
              itemBuilder: (context, i) {
                final s = scenes[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => bt.setColor(s['color'] as Color),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [(s['color'] as Color).withOpacity(0.3), (s['color'] as Color).withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: (s['color'] as Color).withOpacity(0.5), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (s['color'] as Color).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: Text(s['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600))),
                          Icon(Icons.chevron_right, color: (s['color'] as Color).withOpacity(0.7)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
