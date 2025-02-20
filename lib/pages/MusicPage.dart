import 'dart:async'; // Import Timer class
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../database/db_helper.dart';
import '../models/music.dart';
import '../models/succession.dart';
import '../models/succession_statu.dart'; // Correct the import for SuccessionStatu
import 'package:file_picker/file_picker.dart';

class MusicPage extends StatefulWidget {
  final String wsUrl = "ws://192.168.1.102:3000";

  const MusicPage({super.key});

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Music> musicList = [];
  WebSocketChannel? _channel;
  bool isPlaying = false;
  int? playingMusicId;
  int beatsPerChange = 2; // Change every two beats
  Timer? statusTimer;
  int currentStatusIndex = 0;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadMusicFromDatabase();
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(widget.wsUrl);
    _channel!.stream.listen(
      (data) {
        final response = jsonDecode(data);
        if (response['tempo'] != null) {
          _saveMusicTempo(response['tempo']);
        }
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
    _channel?.sink.close();
    statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMusicFromDatabase() async {
    final dbHelper = DBHelper();
    final List<Music> fetchedMusic = await dbHelper.getAllMusic();
    setState(() {
      musicList = fetchedMusic;
    });
  }

  Future<void> _saveMusicTempo(String tempo) async {
    final dbHelper = DBHelper();
    final music = Music(
      title: "New Music",
      tempo: tempo,
    );
    await dbHelper.insertMusic(music);
    _loadMusicFromDatabase();
  }

  Future<void> _deleteMusic(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteMusic(id);
    _loadMusicFromDatabase();
  }

  void _analyzeMusic(File file) {
    final bytes = file.readAsBytesSync();
    final base64File = base64Encode(bytes);
    _channel!.sink.add(jsonEncode({'file': base64File}));
  }

  void _playMusic(Music music) {
    setState(() {
      isPlaying = true;
      playingMusicId = music.id;
    });
    _runStatusSequence(music);
  }

  void _stopMusic() {
    setState(() {
      isPlaying = false;
      playingMusicId = null;
    });
    statusTimer?.cancel();
  }

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

  void _runStatusSequence(Music music) async {
    if (!isPlaying) return;

    final dbHelper = DBHelper();
    final List<Succession> successions = await dbHelper.getAllSuccessions();
    if (successions.isEmpty) return;

    final succession = successions.first; // Use the first succession for now
    final List<SuccessionStatu> successionStatus =
        await dbHelper.getSuccessionStatus(succession.id!);

    if (successionStatus.isEmpty) return;

    final currentStatus = successionStatus[currentStatusIndex];
    print(
        "🔄 Exécution du statut ${currentStatus.id} avec un délai de ${currentStatus.delayAfter} ms");

    // Envoie les valeurs actuelles
    _sendDMXValues(currentStatus.channels);

    // Calculate delay based on tempo and beatsPerChange
    final delay = (60000 / double.parse(music.tempo) * beatsPerChange).round();

    // Programme le délai pour le prochain statut
    statusTimer = Timer(
      Duration(milliseconds: delay),
      () {
        if (!isPlaying) return;
        currentStatusIndex =
            (currentStatusIndex + 1) % succession.statusOrder.length;
        _runStatusSequence(music); // Passe au statut suivant
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Page"),
      ),
      body: musicList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: musicList.length,
              itemBuilder: (context, index) {
                final music = musicList[index];
                return ListTile(
                  title: Text(music.title),
                  subtitle: Text("Tempo: ${music.tempo} BPM"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => isPlaying && playingMusicId == music.id
                            ? _stopMusic()
                            : _playMusic(music),
                        child: Text(isPlaying && playingMusicId == music.id
                            ? "Stop"
                            : "Play"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMusic(music.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            File file = File(result.files.single.path!);
            _analyzeMusic(file);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
