import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService extends ChangeNotifier {
  static const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String charCommandUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _charCommand;

  bool _isConnected = false;
  bool _isScanning = false;
  String _connectionStatus = "Getrennt";

  bool _isPowerOn = false;
  double _brightness = 100.0;
  Color _currentColor = Colors.white;

  StreamSubscription? _connectionSubscription;

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  String get connectionStatus => _connectionStatus;

  bool get isPowerOn => _isPowerOn;
  double get brightness => _brightness;
  Color get currentColor => _currentColor;

  BluetoothService() {
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    try {
      await fbp.FlutterBluePlus.isSupported;
    } catch (e) {
      debugPrint('BLE Init Error: $e');
    }
  }

  Future<void> scanAndConnect() async {
    _isScanning = true;
    _connectionStatus = "Suche...";
    notifyListeners();

    try {
      StreamSubscription? scanSubscription;
      bool deviceFound = false;

      scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) async {
        if (deviceFound) return;

        for (final r in results) {
          final name = r.device.platformName;
          if (name.contains('BlueShift') || name.contains('ESP32')) {
            deviceFound = true;
            await fbp.FlutterBluePlus.stopScan();
            await scanSubscription?.cancel();

            _connectionStatus = "Verbinde...";
            notifyListeners();

            await connectToDevice(r.device);
            return;
          }
        }
      });

      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      await Future.delayed(const Duration(seconds: 10));

      if (!deviceFound) {
        await scanSubscription?.cancel();
        _connectionStatus = "Nicht gefunden";
        _isScanning = false;
        notifyListeners();
      }
    } catch (e) {
      _connectionStatus = "Fehler";
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> cancelScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
    } catch (_) {}
    _isScanning = false;
    _connectionStatus = "Abgebrochen";
    notifyListeners();
  }

  Future<void> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;
      await Future.delayed(const Duration(milliseconds: 500));

      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == charCommandUUID.toLowerCase()) {
              _charCommand = char;
            }
          }
        }
      }

      _isConnected = true;
      _isScanning = false;
      _connectionStatus = "Verbunden";

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _handleDisconnect();
        }
      });

      notifyListeners();
    } catch (e) {
      _connectionStatus = "Fehler";
      _isConnected = false;
      _isScanning = false;
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
    _connectionStatus = "Getrennt";

    _connectionSubscription?.cancel();
    _connectionSubscription = null;

    notifyListeners();
  }

  Future<void> togglePower() async {
    _isPowerOn = !_isPowerOn;
    notifyListeners();
    await _sendCommand(_isPowerOn ? 'LED_ON' : 'LED_OFF');
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
    if (_charCommand != null && _isConnected) {
      try {
        await _charCommand!.write(cmd.codeUnits, withoutResponse: false);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}