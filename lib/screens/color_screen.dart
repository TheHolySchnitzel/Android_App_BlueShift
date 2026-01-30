import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  Color _selected = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothService>(
      builder: (context, bt, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Farbe wÃ¤hlen'),
            backgroundColor: const Color(0xFF191E29),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF191E29), _selected.withOpacity(0.2)],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vorschau der ausgewÃ¤hlten Farbe
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _selected,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: _selected.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          'Voreinstellungen',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 5 Farben in einer Reihe
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                            Colors.yellow,
                            Colors.white,
                          ].map((c) => _colorButton(c)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply-Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      bt.setColor(_selected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Farbe anwenden',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorButton(Color c) {
    return GestureDetector(
      onTap: () => setState(() => _selected = c),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
              color: _selected == c ? Colors.white : Colors.transparent,
              width: 4
          ),
          boxShadow: [
            BoxShadow(
                color: c.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2
            ),
          ],
        ),
      ),
    );
  }
}