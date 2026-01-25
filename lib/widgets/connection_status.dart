import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class ConnectionStatus extends StatelessWidget {
  final BluetoothService bt;

  const ConnectionStatus({super.key, required this.bt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bt.isConnected
            ? const Color(0xFF10B981).withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bt.isConnected ? const Color(0xFF10B981) : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            bt.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: bt.isConnected ? const Color(0xFF10B981) : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            bt.isConnected ? 'Verbunden' : 'Getrennt',
            style: TextStyle(
              color: bt.isConnected ? const Color(0xFF10B981) : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
