import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/utils/frequency_analysis.dart';

class AudioAnalyzerPage extends StatefulWidget {
  @override
  _AudioAnalyzerPageState createState() => _AudioAnalyzerPageState();
}

class _AudioAnalyzerPageState extends State<AudioAnalyzerPage> {
  List<String> _musicFiles = [];
  double _frequencyStart = 0.0;
  double _frequencyEnd = 0.0;

  void _pickMusicFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _musicFiles.add(result.files.single.path!);
      });
    }
  }

  void _analyzeMusic(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultPage(
          filePath: filePath,
          frequencyStart: _frequencyStart,
          frequencyEnd: _frequencyEnd,
        ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Frequency Start'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _frequencyStart = double.parse(value);
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Frequency End'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _frequencyEnd = double.parse(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisResultPage extends StatelessWidget {
  final String filePath;
  final double frequencyStart;
  final double frequencyEnd;

  AnalysisResultPage({
    required this.filePath,
    required this.frequencyStart,
    required this.frequencyEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Perform frequency analysis here and generate data for the graphs
    final frequencyData = analyzeFrequency(filePath, frequencyStart, frequencyEnd);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomLineChart(data: frequencyData),
          ),
        ],
      ),
    );
  }
}

class CustomLineChart extends StatelessWidget {
  final List<Point> data;

  CustomLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: LineChartPainter(data),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Point> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (data.isNotEmpty) {
      path.moveTo(
          data[0].x * size.width, size.height - data[0].y * size.height);
      for (var point in data) {
        path.lineTo(point.x * size.width, size.height - point.y * size.height);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
