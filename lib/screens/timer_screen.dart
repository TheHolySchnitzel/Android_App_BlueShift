import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  // Voreinstellungen in Minuten
  final List<int> _presets = [5, 15, 30, 60];
  int _selectedMinutes = 15;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(BluetoothService bt) {
    if (_isRunning) return;

    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer(bt);
          bt.togglePower(); // LED ausschalten wenn Timer abläuft
        }
      });
    });
  }

  void _stopTimer(BluetoothService bt) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Timer'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Timer Display
                _buildTimerDisplay(),
                const SizedBox(height: 40),
                // Preset Buttons
                if (!_isRunning) _buildPresetButtons(),
                const SizedBox(height: 40),
                // Control Buttons
                _buildControlButtons(bt),
                const Spacer(),
                // Info Text
                _buildInfoText(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay() {
    final progress = _selectedMinutes > 0
        ? (_remainingSeconds / (_selectedMinutes * 60)).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withAlpha(51),
            const Color(0xFF8B5CF6).withAlpha(51),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00D9FF).withAlpha(76),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Ring
          if (_isRunning)
            SizedBox(
              width: 260,
              height: 260,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white.withAlpha(25),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
              ),
            ),
          // Time Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRunning
                    ? _formatTime(_remainingSeconds)
                    : _formatTime(_selectedMinutes * 60),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRunning ? 'Verbleibend' : 'Bereit',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(153),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _presets.map((minutes) {
        final isSelected = _selectedMinutes == minutes;
        return Material(
          color: isSelected
              ? const Color(0xFF00D9FF).withAlpha(76)
              : Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedMinutes = minutes;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withAlpha(51),
                  width: 1.5,
                ),
              ),
              child: Text(
                '$minutes min',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF00D9FF) : Colors.white70,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControlButtons(BluetoothService bt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRunning) ...[
          // Pause Button
          _buildActionButton(
            icon: Icons.pause,
            label: 'Pause',
            color: const Color(0xFFFFA500),
            onTap: _pauseTimer,
          ),
          const SizedBox(width: 16),
          // Stop Button
          _buildActionButton(
            icon: Icons.stop,
            label: 'Stop',
            color: Colors.red,
            onTap: () => _stopTimer(bt),
          ),
        ] else ...[
          // Start Button
          _buildActionButton(
            icon: Icons.play_arrow,
            label: _remainingSeconds > 0 ? 'Fortsetzen' : 'Start',
            color: const Color(0xFF10B981),
            onTap: () => _startTimer(bt),
            large: true,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool large = false,
  }) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(large ? 30 : 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(large ? 30 : 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 40 : 24,
            vertical: large ? 20 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(large ? 30 : 20),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: large ? 28 : 24),
              SizedBox(width: large ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: large ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF00D9FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'LED schaltet sich automatisch aus, wenn der Timer abläuft',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withAlpha(179),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
