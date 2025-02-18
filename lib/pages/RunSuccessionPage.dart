import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../database/db_helper.dart'; // Votre helper pour la base de données
import '../models/succession.dart'; // Le modèle de votre entité Succession

class RunSuccessionPage extends StatefulWidget {
  final String wsUrl = "ws://192.168.1.102:3000";

  const RunSuccessionPage({super.key});

  @override
  _RunSuccessionPageState createState() => _RunSuccessionPageState();
}

class _RunSuccessionPageState extends State<RunSuccessionPage> {
  List<Succession> successions = [];
  bool isRunning = false;
  int currentStatusIndex = 0;
  Timer? statusTimer;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadSuccessionsFromDatabase();
  }

  void _connectWebSocket() {
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
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
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

  /// Envoie des valeurs DMX au serveur via WebSocket
  void _sendDMXValues(List<int> channels) {
    try {
      if (_channel != null && _channel!.sink != null) {
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
  void _toggleRun(Succession succession) {
    if (isRunning) {
      _stopRun();
    } else {
      _startRun(succession);
    }
  }

  void _startRun(Succession succession) {
    isRunning = true;
    _runStatusSequence(succession);
    setState(() {});
  }

  void _stopRun() {
    isRunning = false;
    statusTimer?.cancel();
    setState(() {});
  }

  /// Exécute la séquence des statuts
  void _runStatusSequence(Succession succession) async {
    if (!isRunning || succession.statusOrder.isEmpty) return;

    final dbHelper = DBHelper();
    final currentStatusId = succession.statusOrder[currentStatusIndex];
    final currentStatus = await dbHelper.getStatuById(currentStatusId);

    if (currentStatus != null) {
      // Envoie les valeurs actuelles
      _sendDMXValues(currentStatus.channels);

      // Programme le délai pour le prochain statut
      statusTimer = Timer(
        Duration(milliseconds: currentStatus.delayAfter),
        () {
          if (!isRunning) return;
          currentStatusIndex =
              (currentStatusIndex + 1) % succession.statusOrder.length;
          _runStatusSequence(succession); // Passe au statut suivant
        },
      );
    }
  }

  /// Supprime une succession de la base de données
  Future<void> _deleteSuccession(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteSuccession(id);
    _loadSuccessionsFromDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Succession supprimée avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Run Succession"),
      ),
      body: successions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: successions.length,
              itemBuilder: (context, index) {
                final succession = successions[index];
                return ListTile(
                  title: Text(succession.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _toggleRun(succession),
                        child: Text(isRunning ? "Arrêter" : "Démarrer"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSuccession(succession.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
