import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart'; // Votre helper pour la base de données
import '../models/statu.dart'; // Le modèle de votre entité Statu

class RunPage extends StatelessWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircleDragAndDropPage());
  }
}

//ECHANGE DE CERCLE
class CircleDragAndDropPage extends StatefulWidget {
  final String espIp = "http://192.168.1.112";

  const CircleDragAndDropPage({super.key});
  @override
  _CircleDragAndDropPageState createState() => _CircleDragAndDropPageState();
}

class _CircleDragAndDropPageState extends State<CircleDragAndDropPage> {
  List<Map<String, dynamic>> statusList = [];
  bool isRunning = false;
  int currentStatusIndex = 0;
  Timer? statusTimer;
  // Liste des numéros affichés dans les cercles
  List<int> circles = List.generate(10, (index) => index + 1);

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
        body: jsonEncode({
          'channels': channels
              .asMap()
              .map((index, value) => MapEntry(index.toString(), value))
        }),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Échange de cercles"),
      ),
      body: statusList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: statusList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5 cercles par ligne
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      final fromIndex = details.data;
                      // Échanger les cercles
                      setState(() {
                        final temp = circles[fromIndex];
                        circles[fromIndex] = circles[index];
                        circles[index] = temp;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Draggable<int>(
                        data: index,
                        feedback: CircleWidget(
                          number: circles[index],
                          isDragging: true,
                        ),
                        childWhenDragging: CircleWidget(
                          number: circles[index],
                          isDragging: false,
                          isPlaceholder: true,
                        ),
                        child: CircleWidget(
                          number: circles[index],
                          isDragging: false,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final int number;
  final bool isDragging;
  final bool isPlaceholder;

  const CircleWidget({
    super.key,
    required this.number,
    required this.isDragging,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaceholder ? Colors.grey[300] : Colors.green,
        shape: BoxShape.circle,
        boxShadow: isDragging
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        isPlaceholder ? "" : "$number",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
