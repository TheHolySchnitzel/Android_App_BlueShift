import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class ConnectionStatus extends StatelessWidget {
  final BluetoothService bt;

  const ConnectionStatus({super.key, required this.bt});

  @override
  Widget build(BuildContext context) {
    final isConnected = bt.isConnected;
    final color = isConnected ? const Color(0xFF10B981) : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              bt.connectionStatus,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}