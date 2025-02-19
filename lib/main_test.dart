import 'dart:async';
import 'dart:convert'; // Import nécessaire pour encoder en JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DMXControllerPage(),
    );
  }
}

class DMXControllerPage extends StatefulWidget {
  const DMXControllerPage({super.key});

  @override
  _DMXControllerPageState createState() => _DMXControllerPageState();
}

class _DMXControllerPageState extends State<DMXControllerPage> {
  List<int> dmxChannels = List<int>.filled(512, 0); // Tableau de 512 canaux
  final String espIp = 'http://192.168.1.112';
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Initialiser le timer pour envoyer les valeurs toutes les 200 ms
    _updateTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _sendDMXValues();
    });
  }

  @override
  void dispose() {
    // Arrêter le timer lorsque l'application est fermée
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendDMXValues() async {
    final url = Uri.parse('$espIp/setDMX');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'channels': dmxChannels}),
      );
      if (response.statusCode == 200) {
        print("Values sent successfully: ${response.body}");
      } else {
        print("Failed to send DMX values: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending DMX values: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DMX Controller")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 8, // Affiche seulement 8 canaux pour la démo
          itemBuilder: (context, index) {
            return Column(
              children: [
                Text("Channel ${index + 1}: ${dmxChannels[index]}"),
                Slider(
                  value: dmxChannels[index].toDouble(),
                  min: 0,
                  max: 255,
                  divisions: 255,
                  label: dmxChannels[index].toString(),
                  onChanged: (value) {
                    setState(() {
                      dmxChannels[index] = value.toInt();
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
