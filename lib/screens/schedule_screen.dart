import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Format: "HH:MM", "HH:MM", "Active" (true/false als String)
  final Map<String, List<String>> _schedule = {
    'Mo': ['07:00', '23:00', 'true'],
    'Di': ['07:00', '23:00', 'true'],
    'Mi': ['07:00', '23:00', 'true'],
    'Do': ['07:00', '23:00', 'true'],
    'Fr': ['07:00', '23:00', 'true'],
    'Sa': ['09:00', '00:00', 'true'],
    'So': ['10:00', '23:00', 'true'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Komplett schwarz wie im Bild
      appBar: AppBar(
        title: const Text('Wochenplan'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _schedule.length,
        itemBuilder: (context, index) {
          String day = _schedule.keys.elementAt(index);
          List<String> data = _schedule[day]!;
          bool isActive = data[2] == 'true';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E), // iOS Dark Gray
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoSwitch(
                      value: isActive,
                      activeColor: const Color(0xFF34C759), // iOS Green
                      onChanged: (val) {
                        setState(() {
                          _schedule[day]![2] = val.toString();
                        });
                      },
                    ),
                  ],
                ),
                if (isActive) ...[
                  const Divider(color: Colors.white24, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeColumn("Aufstehen", day, 0),
                      Container(width: 1, height: 40, color: Colors.white10),
                      _buildTimeColumn("Schlafen", day, 1),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendScheduleToESP,
        backgroundColor: const Color(0xFF00D9FF),
        icon: const Icon(Icons.send),
        label: const Text("Speichern"),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String day, int index) {
    String time = _schedule[day]![index];
    return GestureDetector(
      onTap: () => _showIOSPicker(day, index),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  void _showIOSPicker(String day, int index) {
    List<String> parts = _schedule[day]![index].split(':');
    int initialHour = int.parse(parts[0]);
    int initialMinute = int.parse(parts[1]);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: const Color(0xFF1C1C1E),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2024, 1, 1, initialHour, initialMinute),
                onDateTimeChanged: (val) {
                  setState(() {
                    String h = val.hour.toString().padLeft(2, '0');
                    String m = val.minute.toString().padLeft(2, '0');
                    _schedule[day]![index] = "$h:$m";
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF00D9FF))),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  void _sendScheduleToESP() {
    final scheduleString = _schedule.entries.map((e) {
      // Format: Mo:07:00,23:00,1 (1=active, 0=inactive)
      String active = e.value[2] == 'true' ? '1' : '0';
      return '${e.key}:${e.value[0]},${e.value[1]},$active';
    }).join(';');

    Provider.of<BluetoothService>(context, listen: false).setSchedule(scheduleString);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan an Lampe gesendet!')),
    );
  }
}
