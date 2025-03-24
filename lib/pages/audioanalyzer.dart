import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/utils/frequency_analysis.dart';
import 'package:flutter_application_3/pages/graph_page.dart';

class AudioAnalyzerPage extends StatefulWidget {
  @override
  _AudioAnalyzerPageState createState() => _AudioAnalyzerPageState();
}

class _AudioAnalyzerPageState extends State<AudioAnalyzerPage> {
  List<String> _musicFiles = [];

  void _pickMusicFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _musicFiles.add(result.files.single.path!);
      });
    }
  }

  void _analyzeMusic(String filePath) async {
    final points = await analyzeFrequency(filePath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraphPage(
            points: points, audioFilePath: filePath), // Pass the audioFilePath
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Analyzer'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _pickMusicFile,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _musicFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_musicFiles[index]),
                  trailing: ElevatedButton(
                    onPressed: () => _analyzeMusic(_musicFiles[index]),
                    child: Text('Analyze'),
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
