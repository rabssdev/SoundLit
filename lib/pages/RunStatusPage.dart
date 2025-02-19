import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../database/db_helper.dart'; // Votre helper pour la base de données
import '../models/statu.dart'; // Le modèle de votre entité Statu
import '../models/succession.dart'; // Le modèle de votre entité Succession
import '../models/succession_statu.dart'; // Le modèle de votre entité SuccessionStatu

class RunStatusPage extends StatefulWidget {
  final String wsUrl =
      "ws://192.168.1.102:3000"; // Updated to match RunSuccessionPage

  const RunStatusPage({super.key});

  @override
  _RunStatusPageState createState() => _RunStatusPageState();
}

class _RunStatusPageState extends State<RunStatusPage> {
  List<Succession> successions = [];
  List<Map<String, dynamic>> statusList = [];
  bool isRunning = false;
  int currentStatusIndex = 0;
  Timer? statusTimer;
  WebSocketChannel? _channel;
  List<int> channels = List.generate(512, (_) => 0);
  List<int> previousChannels = List.generate(512, (_) => 0);

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadStatusesFromDatabase();
  }

  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(widget.wsUrl);
      _channel!.stream.listen(
        (data) {
          print("📥 Données reçues du serveur : $data");
        },
        onError: (error) {
          print("Erreur WebSocket : $error");
        },
        onDone: () {
          print("Connexion WebSocket fermée");
        },
      );
      print("🔗 Connecté au serveur WebSocket");
    } catch (e) {
      print("Erreur de connexion WebSocket : $e");
    }
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
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

  /// Supprime une succession de la base de données
  Future<void> _deleteSuccession(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteSuccession(id);
    await dbHelper.deleteSuccessionStatus(id);
    _loadSuccessionsFromDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Succession supprimée avec succès')),
    );
  }

  /// Dialogue pour saisir le nom de la succession
  Future<String?> _showNameInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nommer la succession"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Nom"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Enregistre la succession des statuts dans la base de données
  Future<void> _saveSuccession() async {
    final name = await _showNameInputDialog(context);
    if (name != null && name.isNotEmpty) {
      final dbHelper = DBHelper();
      final List<Statu> statusList = await dbHelper.getAllStatus();
      final succession = Succession(
        name: name,
        statusOrder: statusList.map((status) => status.statuId!).toList(),
      );
      final successionId = await dbHelper.insertSuccession(succession);
      print("Succession ID: $successionId"); // Debugging information
      await succession.duplicateStatusToSuccession(statusList, successionId);
      // Verify the inserted SuccessionStatu entries
      final insertedStatus = await dbHelper.getSuccessionStatus(successionId);
      print(
          "Inserted SuccessionStatu entries: $insertedStatus"); // Debugging information
      _loadSuccessionsFromDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Succession enregistrée avec succès')),
      );
    }
  }

  /// Envoie des valeurs DMX au serveur via WebSocket
  void _sendDMXValues(List<int> channels) {
    try {
      if (_channel != null) {
        Map<String, int> delta = {};
        for (int i = 0; i < channels.length; i++) {
          delta[i.toString()] = channels[i];
        }
        _channel!.sink.add(jsonEncode({'channels': delta}));
        print("📤 Données envoyées au serveur : $delta");
      }
    } catch (e) {
      print("Erreur d'envoi des données WebSocket : $e");
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
    print(
        "🔄 Exécution du statut ${currentStatus['id']} avec un délai de ${currentStatus['delayAfter']} ms");
    print("hello hello");
    // Envoie les valeurs actuelles
    _sendDMXValues(currentStatus['channels']);

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

  /// Met à jour le délai d'un statut et le sauvegarde dans la base de données
  Future<void> _updateDelay(int index, int newDelay) async {
    setState(() {
      statusList[index]['delayAfter'] = newDelay;
    });

    final dbHelper = DBHelper();
    await dbHelper.updateStatuDelay(statusList[index]['id'], newDelay);
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

  /// Charge les successions depuis la base de données
  Future<void> _loadSuccessionsFromDatabase() async {
    final dbHelper = DBHelper();
    final List<Succession> fetchedSuccessions =
        await dbHelper.getAllSuccessions();
    setState(() {
      successions = fetchedSuccessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Run Status"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSuccession,
          ),
        ],
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
                        return ListTile(
                          key: ValueKey(statusList[index]['id']),
                          leading: CircleWidget(
                            number: statusList[index]['id'],
                            isDragging: false,
                          ),
                          title: Text(
                            "Delay: ${statusList[index]['delayAfter']} ms",
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final newDelay = await _showDelayInputDialog(
                                  context, statusList[index]['delayAfter']);
                              if (newDelay != null) {
                                _updateDelay(index, newDelay);
                              }
                            },
                          ),
                          onTap: () {
                            _sendDMXValues(statusList[index]['channels']);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleRun,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: Text(isRunning ? "Arrêter" : "Démarrer"),
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
    super.key,
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
