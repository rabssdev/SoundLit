import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart'; // Votre helper pour la base de données
import '../models/statu.dart'; // Le modèle de votre entité Statu

class RunStatusPage extends StatefulWidget {
  final String espIp = "http://192.168.1.112";

  RunStatusPage();

  @override
  _RunStatusPageState createState() => _RunStatusPageState();
}

class _RunStatusPageState extends State<RunStatusPage> {
  List<Map<String, dynamic>> statusList = [];
  bool isRunning = false;
  int currentStatusIndex = 0;
  Timer? statusTimer;

  @override
  void initState() {
    super.initState();
    _loadStatusesFromDatabase();
  }

  /// Charge les statuts depuis la base de données
  Future<void> _loadStatusesFromDatabase() async {
    final dbHelper = DBHelper();
    final List<Statu> fetchedStatuses = await dbHelper.getAllStatus();
    setState(() {
      statusList = fetchedStatuses
          .map((statu) => {
                'id': statu.statuId,
                'channels': statu.channels,
                'delayAfter': statu.delayAfter,
              })
          .toList();
    });
  }

  /// Envoie des valeurs DMX au serveur ESP8266
  Future<void> _sendDMXValues(List<int> channels) async {
    final url = Uri.parse('${widget.espIp}/setDMX');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'channels': channels}),
      );
      if (response.statusCode == 200) {
        print("Valeurs envoyées avec succès : ${response.body}");
      } else {
        print("Échec de l'envoi des valeurs : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi : $e");
    }
  }

  /// Démarre ou arrête l'envoi des statuts
  void _toggleRun() {
    if (isRunning) {
      _stopRun();
    } else {
      _startRun();
    }
  }

  void _startRun() {
    isRunning = true;
    _runStatusSequence();
    setState(() {});
  }

  void _stopRun() {
    isRunning = false;
    statusTimer?.cancel();
    setState(() {});
  }

  /// Exécute la séquence des statuts
  void _runStatusSequence() async {
    if (!isRunning || statusList.isEmpty) return;

    final currentStatus = statusList[currentStatusIndex];

    // Envoie les valeurs actuelles
    await _sendDMXValues(currentStatus['channels']);

    // Programme le délai pour le prochain statut
    statusTimer = Timer(
      Duration(milliseconds: currentStatus['delayAfter']),
      () {
        if (!isRunning) return;
        currentStatusIndex = (currentStatusIndex + 1) % statusList.length;
        _runStatusSequence(); // Passe au statut suivant
      },
    );
  }

  /// Met à jour le délai d'un statut
  void _updateDelay(int index, int newDelay) {
    setState(() {
      statusList[index]['delayAfter'] = newDelay;
    });
  }

  /// Dialogue pour saisir un nouveau délai
  Future<int?> _showDelayInputDialog(
      BuildContext context, int currentDelay) async {
    TextEditingController controller =
        TextEditingController(text: currentDelay.toString());
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le délai"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Délai en ms"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                Navigator.of(context).pop(value);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Ajout d'une variable pour suivre le statut sélectionné
  int? selectedStatusId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Run Status"),
      ),
      body: statusList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: statusList.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        setState(() {
                          final item = statusList.removeAt(oldIndex);
                          statusList.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final status = statusList[index];
                        return ListTile(
                          key: ValueKey(status['id']),
                          leading: CircleWidget(
                            number: status['id'],
                            isDragging: false,
                          ),
                          title: Text(
                            "Delay: ${status['delayAfter']} ms",
                            style: const TextStyle(fontSize: 16),
                          ),
                          tileColor: selectedStatusId == status['id']
                              ? Colors.blueAccent.withOpacity(0.2)
                              : null,
                          onTap: () async {
                            if (!isRunning) {
                              setState(() {
                                selectedStatusId = status['id'];
                              });
                              await _sendDMXValues(status['channels']);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final newDelay = await _showDelayInputDialog(
                                  context, status['delayAfter']);
                              if (newDelay != null) {
                                _updateDelay(index, newDelay);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleRun,
                    child: Text(isRunning ? "Arrêter" : "Démarrer"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final int number;
  final bool isDragging;

  const CircleWidget({
    required this.number,
    required this.isDragging,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, // Définir une largeur explicite
      height: 40, // Définir une hauteur explicite
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        "$number",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
