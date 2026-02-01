import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import '../widgets/connection_status.dart';
import '../widgets/power_switch.dart';
import '../widgets/brightness_slider.dart';
import 'color_temperature_screen.dart';
import 'scenes_screen.dart';
import 'timer_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E21),
                const Color(0xFF191E29),
                bt.isPowerOn ? bt.currentColor.withAlpha(25) : const Color(0xFF0A0E21),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(bt),
                  Expanded(
                    child: bt.isConnected ? _buildControls(context, bt) : _buildDisconnected(bt),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BluetoothService bt) {
    return Row(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF8B5CF6)],
            ).createShader(b),
            child: const Text('BlueShift', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
        ),
        if (bt.isConnected) ...[
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: bt.disconnect,
            style: IconButton.styleFrom(backgroundColor: Colors.red.withAlpha(25)),
          ),
          const SizedBox(width: 8),
        ],
        ConnectionStatus(bt: bt),
      ],
    );
  }

  Widget _buildControls(BuildContext context, BluetoothService bt) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          PowerSwitch(bt: bt),
          const SizedBox(height: 16),
          _buildCompactInfo(context, bt), // Jetzt dynamisch!
          const SizedBox(height: 20),
          BrightnessSlider(bt: bt),
          const SizedBox(height: 24),
          _buildGrid(context, bt),
        ],
      ),
    );
  }

  // Hier ist die Logik für "Heute/Morgen"
  Widget _buildCompactInfo(BuildContext context, BluetoothService bt) {
    // 1. Bestimmen welcher Tag heute ist
    final now = DateTime.now();
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    // weekday 1=Mo .. 7=So. Array Index 0..6
    final todayKey = days[now.weekday - 1];
    final tomorrowKey = days[now.weekday % 7]; // Modulo für Sonntag->Montag Übergang

    final todayData = bt.weeklySchedule[todayKey]!;
    final tomData = bt.weeklySchedule[tomorrowKey]!;

    // Helper für Text-Formatierung
    String formatText(String label, List<String> data) {
      if (data[2] != 'true') return "$label: Inaktiv";
      return "$label: ${data[0]} - ${data[1]}";
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: Color(0xFF00D9FF), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      formatText("Heute", todayData),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                  const SizedBox(height: 2),
                  Text(
                      formatText("Morgen", tomData),
                      style: const TextStyle(color: Colors.white54, fontSize: 11)
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, BluetoothService bt) {
    final items = [
      ('Licht', Icons.tonality, const Color(0xFFFF6B9D), (ctx) => const ColorTemperatureScreen()),
      ('Szenen', Icons.auto_awesome, const Color(0xFF8B5CF6), (ctx) => const ScenesScreen()),
      ('Timer', Icons.timer, const Color(0xFF10B981), (ctx) => const TimerScreen()),
      ('Plan', Icons.calendar_month, const Color(0xFF00D9FF), (ctx) => const ScheduleScreen()),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: items.map((item) => _gridCard(context, item.$1, item.$2, item.$3, bt.isPowerOn, item.$4)).toList(),
    );
  }

  Widget _gridCard(BuildContext context, String title, IconData icon, Color color, bool enabled, WidgetBuilder pageBuilder) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => Navigator.push(context, MaterialPageRoute(builder: pageBuilder)) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: enabled ? [color.withAlpha(50), color.withAlpha(10)] : [Colors.white10, Colors.white10]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: enabled ? color.withAlpha(80) : Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: enabled ? color : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: enabled ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnected(BluetoothService bt) {
    return Center(
      child: bt.isScanning
          ? const CircularProgressIndicator(color: Color(0xFF00D9FF))
          : ElevatedButton.icon(
        onPressed: bt.scanAndConnect,
        icon: const Icon(Icons.bluetooth),
        label: const Text('Verbinden'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
