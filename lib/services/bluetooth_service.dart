import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService extends ChangeNotifier {
  static const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String charCommandUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  fbp.BluetoothDevice? _device;
  fbp.BluetoothCharacteristic? _charCmd;

  bool _scanning = false;
  bool _powerOn = false;
  double _brightness = 100.0;
  Color _color = const Color(0xFF00D9FF);
  String _mode = "BlueShift";
  String _status = "Getrennt";

  // ZENTRALE DATEN FÜR DEN WOCHENPLAN
  // Key: Tag, Value: [Start, Ende, Active("true"/"false")]
  Map<String, List<String>> _weeklySchedule = {
    'Mo': ['07:00', '23:00', 'true'],
    'Di': ['07:00', '23:00', 'true'],
    'Mi': ['07:00', '23:00', 'true'],
    'Do': ['07:00', '23:00', 'true'],
    'Fr': ['07:00', '23:00', 'true'],
    'Sa': ['09:00', '00:00', 'true'],
    'So': ['10:00', '23:00', 'true'],
  };

  // Getters
  bool get isConnected => _device?.isConnected ?? false;
  bool get isScanning => _scanning;
  String get connectionStatus => _status;
  bool get isPowerOn => _powerOn;
  double get brightness => _brightness;
  Color get currentColor => _color;
  String get activeMode => _mode;
  Map<String, List<String>> get weeklySchedule => _weeklySchedule;

  BluetoothService() {
    // _initBluetooth(); // Nicht zwingend nötig wenn scanAndConnect alles macht
  }

  Future scanAndConnect() async {
    _scanning = true;
    _status = "Suche...";
    notifyListeners();

    try {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      fbp.FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          if (r.device.platformName.contains('BlueShift') || r.device.platformName.contains('ESP32')) {
            await fbp.FlutterBluePlus.stopScan();
            _status = "Verbinde...";
            notifyListeners();
            await _connect(r.device);
            return;
          }
        }
      });

      await Future.delayed(const Duration(seconds: 6));
      if (!isConnected) {
        _status = "Nicht gefunden";
        _scanning = false;
        notifyListeners();
      }
    } catch (e) {
      _status = "Fehler";
      _scanning = false;
      notifyListeners();
    }
  }

  Future _connect(fbp.BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      _device = device;

      final services = await device.discoverServices();
      for (var s in services) {
        if (s.uuid.toString() == serviceUUID) {
          for (var c in s.characteristics) {
            if (c.uuid.toString() == charCommandUUID) {
              _charCmd = c;
              _status = "Verbunden";
              _scanning = false;

              device.connectionState.listen((state) {
                if (state == fbp.BluetoothConnectionState.disconnected) disconnect();
              });

              notifyListeners();
              return;
            }
          }
        }
      }
    } catch (e) {
      disconnect();
    }
  }

  Future disconnect() async {
    try { await _device?.disconnect(); } catch (_) {}
    _device = null;
    _status = "Getrennt";
    _scanning = false;
    notifyListeners();
  }

  Future togglePower() async {
    _powerOn = !_powerOn;
    notifyListeners();
    await _send(_powerOn ? 'LED_ON' : 'LED_OFF');
  }

  Future setBrightness(double v) async {
    _brightness = v;
    notifyListeners();
    await _send('BRIGHT:${v.toInt()}');
  }

  Future setMode(String mode) async {
    _mode = mode;
    notifyListeners();
    if (mode == "BlueShift") _color = const Color(0xFF00D9FF);
  }

  Future setColorTemperature(int kelvin) async {
    await _send('CCT:$kelvin');
  }

  // Update Methode für den Schedule
  Future updateSchedule(Map<String, List<String>> newSchedule) async {
    // 1. Lokal speichern
    _weeklySchedule = Map.from(newSchedule);
    notifyListeners();

    // 2. String für ESP bauen
    final str = _weeklySchedule.entries.map((e) {
      String active = e.value[2] == 'true' ? '1' : '0';
      return '${e.key}:${e.value[0]},${e.value[1]},$active';
    }).join(';');

    await _send('SCHEDULE:$str');
  }

  Future _send(String cmd) async {
    if (_charCmd != null && isConnected) {
      try { await _charCmd!.write(cmd.codeUnits); } catch (_) {}
    }
  }
}
