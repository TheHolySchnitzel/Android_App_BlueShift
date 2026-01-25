import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import '../widgets/connection_status.dart';
import '../widgets/power_switch.dart';
import '../widgets/brightness_slider.dart';
import 'color_screen.dart';
import 'scenes_screen.dart';
import 'timer_screen.dart';
import 'room_screen.dart';

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
                  bt.isPowerOn ? bt.currentColor.withOpacity(0.1) : const Color(0xFF0A0E21),
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
              // BlueShift Logo - animiert
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

              // Status - FESTE Position, FESTE Breite
              SizedBox(
                width: 130,
                child: ConnectionStatus(bt: bt),
              ),
            ],
          ),

          if (bt.isConnected) ...[
            const SizedBox(height: 12),
            _buildQuickStats(bt),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BluetoothService bt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
              Icons.speed,
              bt.dataRate > 0 ? '${bt.dataRate.toStringAsFixed(2)} KB/s' : '--',
              const Color(0xFF00D9FF)
          ),
          Container(width: 1, height: 24, color: Colors.white10),
          _statItem(
              Icons.wifi,
              bt.signalStrength != 0 ? '${bt.signalStrength} dBm' : '--',
              const Color(0xFF8B5CF6)
          ),
          Container(width: 1, height: 24, color: Colors.white10),
          _statItem(
              Icons.power,
              bt.powerConsumption > 0 ? '${bt.powerConsumption}W' : '--',
              const Color(0xFF10B981)
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600
              ),
              overflow: TextOverflow.ellipsis,
            ),
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

          // Trenn-Button HIER - über dem Hauptschalter
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: bt.disconnect,
              icon: const Icon(Icons.link_off, size: 18),
              label: const Text('Trennen'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          PowerSwitch(bt: bt),
          const SizedBox(height: 16),
          BrightnessSlider(bt: bt),
          const SizedBox(height: 16),
          _buildGrid(bt),
          const SizedBox(height: 16),
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
        _gridCard('Farben', Icons.palette, const Color(0xFFFF6B9D), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorScreen()));
        }),
        _gridCard('Szenen', Icons.auto_awesome, const Color(0xFF8B5CF6), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScenesScreen()));
        }),
        _gridCard('Timer', Icons.timer, const Color(0xFF10B981), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerScreen()));
        }),
        _gridCard('Raum', Icons.grid_view, const Color(0xFF00D9FF), enabled, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomScreen()));
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
                ? [color.withOpacity(0.3), color.withOpacity(0.1)]
                : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
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
          // Bluetooth-Icon-Button mit Text
          ElevatedButton.icon(
            onPressed: bt.isScanning ? null : () => bt.scanAndConnect(),
            icon: bt.isScanning
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.bluetooth, size: 28),
            label: Text(
              bt.isScanning ? 'Suche...' : 'Verbinden',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
