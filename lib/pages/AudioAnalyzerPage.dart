import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

class AudioAnalyzerPage extends StatefulWidget {
  const AudioAnalyzerPage({super.key});

  @override
  _AudioAnalyzerPageState createState() => _AudioAnalyzerPageState();
}

class _AudioAnalyzerPageState extends State<AudioAnalyzerPage> {
  final List<String> _musicFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  bool _isPlaying = false;
  String? _currentFile;
  double _startFrequency = 0.0;
  double _endFrequency = 0.0;
  double _dbLimit = 0.0;
  bool _isDbExceeded = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _soundPlayer.openPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _soundPlayer.closePlayer();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _pickMusicFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _musicFiles.add(result.files.single.path!);
      });
    }
  }

  void _playMusic(String filePath) async {
    if (_startFrequency == 0.0 || _endFrequency == 0.0 || _dbLimit == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields before playing music')),
      );
      return;
    }

    await _audioPlayer.stop(); // Ensure any previous instance is stopped
    await _soundPlayer.stopPlayer(); // Ensure any previous instance is stopped
    await _audioPlayer.play(DeviceFileSource(filePath));
    setState(() {
      _isPlaying = true;
      _currentFile = filePath;
    });
    _monitorAudio();
  }

  void _stopMusic() async {
    await _audioPlayer.stop();
    await _soundPlayer.stopPlayer();
    setState(() {
      _isPlaying = false;
      _currentFile = null;
      _isDbExceeded = false;
    });
    _blinkTimer?.cancel();
  }

  void _monitorAudio() {
    _soundPlayer.startPlayer(fromURI: _currentFile, codec: Codec.mp3);
    _soundPlayer.onProgress!.listen((event) {
      // Analyze the audio data here and update _isDbExceeded
      // This is a placeholder for actual frequency and dB analysis
      setState(() {
        _isDbExceeded = _checkDbExceeded();
      });
    });

    _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isDbExceeded = !_isDbExceeded;
      });
    });
  }

  bool _checkDbExceeded() {
    // Placeholder logic for checking if dB limit is exceeded
    // Implement actual frequency and dB analysis here
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Analyzer Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickMusicFile,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration:
                const InputDecoration(labelText: 'Start Frequency (Hz)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _startFrequency = double.tryParse(value) ?? 0.0;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'End Frequency (Hz)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _endFrequency = double.tryParse(value) ?? 0.0;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'dB Limit'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _dbLimit = double.tryParse(value) ?? 0.0;
            },
          ),
          if (_isPlaying)
            CircleAvatar(
              radius: 30,
              backgroundColor: _isDbExceeded ? Colors.red : Colors.green,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _musicFiles.length,
              itemBuilder: (context, index) {
                final file = _musicFiles[index];
                return ListTile(
                  title: Text(file.split('/').last),
                  trailing: _isPlaying && _currentFile == file
                      ? IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _stopMusic,
                        )
                      : IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => _playMusic(file),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
