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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        return Scaffold(
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
              child: Column(
                children: [
                  _buildHeader(bt),
                  Expanded(
                    child: bt.isConnected
                        ? _buildContent(bt)
                        : _buildDisconnected(bt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BluetoothService bt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF8B5CF6)],
                  ).createShader(bounds),
                  child: const Text(
                    'BlueShift',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
              ),
              if (bt.isConnected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Material(
                    color: Colors.red.withAlpha(25),
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.red, width: 1.5),
                    ),
                    child: InkWell(
                      onTap: bt.disconnect,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: 110,
                child: ConnectionStatus(bt: bt),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildContent(BluetoothService bt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          PowerSwitch(bt: bt),
          const SizedBox(height: 12),
          _buildTodayTomorrowInfo(), // Kleine Anzeige
          const SizedBox(height: 16),
          BrightnessSlider(bt: bt),
          const SizedBox(height: 24),
          _buildGrid(bt),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

// NEU: Nur Visualisierung für heute/morgen, NICHT editierbar
  Widget _buildTodayTomorrowInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Color(0xFF00D9FF), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heute: Aufstehen 07:00, Schlafen 23:00',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'Morgen: Aufstehen 07:00, Schlafen 23:00',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context, // KORREKT: Den lokalen BuildContext verwenden
                MaterialPageRoute(builder: (_) => const ScheduleScreen()),
              );
            },
            child: const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BluetoothService bt) {
    final enabled = bt.isPowerOn;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _gridCard('Farbtemperatur', Icons.tonality, const Color(0xFFFF6B9D), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorScreen()));
        }),
        _gridCard('Szenen', Icons.auto_awesome, const Color(0xFF8B5CF6), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScenesScreen()));
        }),
        _gridCard('Timer', Icons.timer, const Color(0xFF10B981), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerScreen()));
        }),
        _gridCard('Plan', Icons.schedule, const Color(0xFF00D9FF), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
        }),
      ],
    );
  }

  Widget _gridCard(String title, IconData icon, Color color, bool enabled, VoidCallback? onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [color.withAlpha(76), color.withAlpha(25)]
                : [Colors.grey.withAlpha(25), Colors.grey.withAlpha(12)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? color.withAlpha(76) : Colors.grey.withAlpha(51),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled ? color.withAlpha(51) : Colors.grey.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: enabled ? color : Colors.grey, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnected(BluetoothService bt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (bt.isScanning) ...[
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFF00D9FF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              bt.connectionStatus,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => bt.cancelScan(),
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Abbrechen'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withAlpha(25),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => bt.scanAndConnect(),
              icon: const Icon(Icons.bluetooth, size: 28),
              label: const Text(
                'Verbinden',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}