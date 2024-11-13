import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DMXControllerPage(),
    );
  }
}

class DMXControllerPage extends StatefulWidget {
  @override
  _DMXControllerPageState createState() => _DMXControllerPageState();
}

class _DMXControllerPageState extends State<DMXControllerPage> {
  double channel1 = 0;
  double channel2 = 0;
  double channel3 = 0;
  double channel4 = 0;

  double _lastChannel1 = 0;
  double _lastChannel2 = 0;
  double _lastChannel3 = 0;
  double _lastChannel4 = 0;

  final String espIp = 'http://192.168.1.112';
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Initialiser le timer pour envoyer les valeurs toutes les 200 ms
    _updateTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
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
    // Vérifier si les valeurs ont changé avant d'envoyer la requête
    if (channel1 != _lastChannel1 || channel2 != _lastChannel2 || channel3 != _lastChannel3 || channel4 != _lastChannel4) {
      final url = Uri.parse('$espIp/setDMX?channel1=${channel1.toInt()}&channel2=${channel2.toInt()}&channel3=${channel3.toInt()}&channel4=${channel4.toInt()}');
      try {
        await http.get(url);
        print("Values sent: channel1: $channel1, channel2: $channel2, channel3: $channel3, channel4: $channel4");
        
        // Mettre à jour les dernières valeurs envoyées
        _lastChannel1 = channel1;
        _lastChannel2 = channel2;
        _lastChannel3 = channel3;
        _lastChannel4 = channel4;
      } catch (e) {
        print("Failed to send DMX values: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DMX Controller")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Channel 1: ${channel1.toInt()}"),
            Slider(
              value: channel1,
              min: 0,
              max: 255,
              divisions: 255,
              label: channel1.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  channel1 = value;
                });
              },
            ),
            Text("Channel 2: ${channel2.toInt()}"),
            Slider(
              value: channel2,
              min: 0,
              max: 255,
              divisions: 255,
              label: channel2.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  channel2 = value;
                });
              },
            ),
            Text("Channel 3: ${channel3.toInt()}"),
            Slider(
              value: channel3,
              min: 0,
              max: 255,
              divisions: 255,
              label: channel3.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  channel3 = value;
                });
              },
            ),
            Text("Channel 4: ${channel4.toInt()}"),
            Slider(
              value: channel4,
              min: 0,
              max: 255,
              divisions: 255,
              label: channel4.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  channel4 = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
