import 'package:flutter/material.dart';
import '../../services/bluetooth_service.dart';

class PowerSwitch extends StatelessWidget {
  final BluetoothService bt;

  const PowerSwitch({super.key, required this.bt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bt.isPowerOn
              ? [const Color(0xFF00D9FF).withOpacity(0.3), const Color(0xFF8B5CF6).withOpacity(0.3)]
              : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: bt.isPowerOn ? const Color(0xFF00D9FF).withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: bt.isPowerOn
            ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hauptschalter', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  bt.isPowerOn ? 'Eingeschaltet' : 'Ausgeschaltet',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: bt.isConnected ? bt.togglePower : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: bt.isPowerOn
                      ? [const Color(0xFF00D9FF), const Color(0xFF8B5CF6)]
                      : [Colors.grey.shade700, Colors.grey.shade600],
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: bt.isPowerOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    Icons.power_settings_new,
                    size: 20,
                    color: bt.isPowerOn ? const Color(0xFF00D9FF) : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
