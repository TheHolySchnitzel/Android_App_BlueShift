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

  // WICHTIG: Map immer initialisiert lassen, damit Home Screen nicht crasht
  Map<String, List<String>> _weeklySchedule = {
    'Mo': ['07:00', '23:00', 'true'],
    'Di': ['07:00', '23:00', 'true'],
    'Mi': ['07:00', '23:00', 'true'],
    'Do': ['07:00', '23:00', 'true'],
    'Fr': ['07:00', '23:00', 'true'],
    'Sa': ['09:00', '00:00', 'true'],
    'So': ['10:00', '23:00', 'true'],
  };

  bool get isConnected => _device?.isConnected ?? false;
  bool get isScanning => _scanning;
  String get connectionStatus => _status;
  bool get isPowerOn => _powerOn;
  double get brightness => _brightness;
  Color get currentColor => _color;
  String get activeMode => _mode;
  Map<String, List<String>> get weeklySchedule => _weeklySchedule;

  Future scanAndConnect() async {
    if (isConnected) return; // Schon verbunden? Raus.

    _scanning = true;
    _status = "Suche...";
    notifyListeners();

    try {
      // 1. Sicherheitshalber erst stoppen, falls noch was läuft
      await fbp.FlutterBluePlus.stopScan();

      // 2. Scan starten (Timeout erhöht auf 10s)
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true, // Wichtig für neue Android Versionen!
      );

      // 3. Listener auf Ergebnisse
      var subscription = fbp.FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          // Prüfen auf Name ODER UUID (falls Name nicht advertised wird)
          bool matchName = r.device.platformName.contains('BlueShift') ||
              r.device.platformName.contains('ESP32');
          // Manche BLE devices zeigen Namen erst nach Connect, daher UUID Check:
          bool matchUUID = r.advertisementData.serviceUuids.contains(serviceUUID);

          if (matchName || matchUUID) {
            print("Gerät gefunden: ${r.device.platformName}");
            await fbp.FlutterBluePlus.stopScan();
            _status = "Verbinde...";
            notifyListeners();
            await _connect(r.device);
            return; // Gefunden, Listener beendet durch _connect Logik (bzw. Stream Cancel)
          }
        }
      }, onError: (e) {
        print("Scan Error: $e");
        _status = "Fehler";
        _scanning = false;
        notifyListeners();
      });

      // Warten bis Timeout oder Verbunden
      await Future.delayed(const Duration(seconds: 10));

      // Aufräumen
      await subscription.cancel();
      if (!isConnected && _scanning) {
        _status = "Nicht gefunden";
        _scanning = false;
        notifyListeners();
      }

    } catch (e) {
      print("Global Scan Error: $e");
      _status = "Fehler";
      _scanning = false;
      notifyListeners();
    }
  }

  Future _connect(fbp.BluetoothDevice device) async {
    try {
      // AutoConnect false ist meist stabiler für direkte Verbindung
      await device.connect(autoConnect: false, mtu: null);
      _device = device;

      // Kleines Delay für Stabilität
      await Future.delayed(const Duration(milliseconds: 500));

      // Services entdecken (Wichtig!)
      final services = await device.discoverServices();
      bool charFound = false;

      for (var s in services) {
        if (s.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var c in s.characteristics) {
            if (c.uuid.toString().toLowerCase() == charCommandUUID.toLowerCase()) {
              _charCmd = c;
              charFound = true;
              break;
            }
          }
        }
        if (charFound) break;
      }

      if (charFound) {
        _status = "Verbunden";
        _scanning = false;

        device.connectionState.listen((state) {
          if (state == fbp.BluetoothConnectionState.disconnected) {
            disconnect();
          }
        });

        notifyListeners();
      } else {
        print("Service/Charakteristik nicht gefunden!");
        await device.disconnect();
        _status = "Fehler (Protokoll)";
        _scanning = false;
        notifyListeners();
      }

    } catch (e) {
      print("Connection Error: $e");
      disconnect();
    }
  }

  Future disconnect() async {
    try { await _device?.disconnect(); } catch (_) {}
    _device = null;
    _charCmd = null;
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

  Future updateSchedule(Map<String, List<String>> newSchedule) async {
    _weeklySchedule = Map.from(newSchedule);
    notifyListeners();
    final str = _weeklySchedule.entries.map((e) {
      String active = e.value[2] == 'true' ? '1' : '0';
      return '${e.key}:${e.value[0]},${e.value[1]},$active';
    }).join(';');
    await _send('SCHEDULE:$str');
  }

  Future _send(String cmd) async {
    if (_charCmd != null && isConnected) {
      try {
        await _charCmd!.write(cmd.codeUnits, withoutResponse: false);
      } catch (e) {
        print("Send Error: $e");
      }
    }
  }
}
