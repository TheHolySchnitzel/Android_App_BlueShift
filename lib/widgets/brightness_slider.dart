import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class BrightnessSlider extends StatefulWidget {
  final BluetoothService bt;

  const BrightnessSlider({super.key, required this.bt});

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider> {
  Timer? _debounce;
  double _localBrightness = 100.0;

  @override
  void initState() {
    super.initState();
    _localBrightness = widget.bt.brightness;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onBrightnessChanged(double value) {
    setState(() {
      _localBrightness = value;
    });

    // Timer abbrechen falls noch aktiv
    _debounce?.cancel();

    // Neuer Timer: erst nach 300ms senden
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.bt.setBrightness(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.bt.isConnected && widget.bt.isPowerOn;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: enabled ? const Color(0xFFFBBC05).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny, color: enabled ? const Color(0xFFFBBC05) : Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Helligkeit',
                    style: TextStyle(color: enabled ? Colors.white : Colors.grey, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                '${_localBrightness.toInt()}%',
                style: TextStyle(
                  color: enabled ? const Color(0xFFFBBC05) : Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              activeTrackColor: enabled ? const Color(0xFFFBBC05) : Colors.grey,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: enabled ? const Color(0xFFFBBC05) : Colors.grey,
            ),
            child: Slider(
              value: _localBrightness,
              min: 0,
              max: 100,
              onChanged: enabled ? _onBrightnessChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}