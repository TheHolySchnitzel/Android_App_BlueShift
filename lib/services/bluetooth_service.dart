import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService extends ChangeNotifier {
  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _characteristic;

  bool _isConnected = false;
  bool _isScanning = false;
  int _signalStrength = 0;  // RSSI
  double _dataRate = 0.0;

  double _temperature = 0.0;
  double _humidity = 0.0;
  int _powerConsumption = 0;

  bool _isPowerOn = false;
  double _brightness = 100.0;
  Color _currentColor = Colors.white;

  // Getters
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  int get signalStrength => _signalStrength;
  double get dataRate => _dataRate;
  double get temperature => _temperature;
  double get humidity => _humidity;
  int get powerConsumption => _powerConsumption;
  bool get isPowerOn => _isPowerOn;
  double get brightness => _brightness;
  Color get currentColor => _currentColor;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;

  Timer? _rssiTimer;
  StreamSubscription? _connectionSubscription;

  BluetoothService() {
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    try {
      final isSupported = await fbp.FlutterBluePlus.isSupported;
      if (!isSupported) {
        debugPrint('Bluetooth not supported');
      }
    } catch (e) {
      debugPrint('Bluetooth init error: $e');
    }
  }

  // MANUELLES Scannen - nur über Button!
  Future<void> scanAndConnect() async {
    _isScanning = true;
    notifyListeners();

    try {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

      await for (final results in fbp.FlutterBluePlus.scanResults) {
        for (final r in results) {
          if (r.device.platformName == 'BlueShift_ESP32_S3') {
            await fbp.FlutterBluePlus.stopScan();
            _isScanning = false;
            notifyListeners();
            await connectToDevice(r.device);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Scan error: $e');
    }

    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _isConnected = true;

      // RSSI (Signalstärke) alle 2 Sekunden abrufen
      _rssiTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (_isConnected && _connectedDevice != null) {
          try {
            final rssi = await _connectedDevice!.readRssi();
            _signalStrength = rssi;
            notifyListeners();
          } catch (_) {}
        }
      });

      // Verbindungsstatus überwachen
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _handleDisconnect();
        }
      });

      notifyListeners();

      final services = await device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            _characteristic = char;
          }
          // Falls ESP später Notify-Characteristic für Sensordaten hat:
          if (char.properties.notify) {
            await char.setNotifyValue(true);
            char.lastValueStream.listen((value) {
              _parseSensorData(value);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
    }
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _connectedDevice = null;
    _isConnected = false;
    _signalStrength = 0;
    _dataRate = 0.0;
    _temperature = 0.0;
    _humidity = 0.0;
    _powerConsumption = 0;
    _rssiTimer?.cancel();
    _connectionSubscription?.cancel();
    notifyListeners();
  }

  void _parseSensorData(List<int> data) {
    // Beispiel: ESP sendet JSON oder CSV
    // z.B. "TEMP:22.5,HUMID:45.2,POWER:12"
    String str = String.fromCharCodes(data);
    debugPrint('Sensor-Daten: $str');

    // Hier würdest du parsen, z.B.:
    // if (str.contains('TEMP:')) { ... }
    // Vorerst: Platzhalter
  }

  Future<void> togglePower() async {
    _isPowerOn = !_isPowerOn;
    notifyListeners();
    final cmd = _isPowerOn ? 'LED_ON' : 'LED_OFF';
    await _sendCommand(cmd);
  }

  Future<void> setBrightness(double value) async {
    _brightness = value;
    notifyListeners();
    await _sendCommand('BRIGHT:${value.toInt()}');
  }

  Future<void> setColor(Color color) async {
    _currentColor = color;
    notifyListeners();
    await _sendCommand('COLOR:${color.red},${color.green},${color.blue}');
  }

  Future<void> _sendCommand(String cmd) async {
    if (_characteristic != null && _isConnected) {
      try {
        await _characteristic!.write(cmd.codeUnits, withoutResponse: false);
        // Datenrate simuliert als Bytes/Sekunde
        _dataRate = cmd.length / 1024.0; // KB/s
        notifyListeners();
      } catch (e) {
        debugPrint('Send error: $e');
      }
    }
  }

  @override
  void dispose() {
    _rssiTimer?.cancel();
    _connectionSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
