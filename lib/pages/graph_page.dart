import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/utils/frequency_analysis.dart';
import 'package:audioplayers/audioplayers.dart';

class GraphPage extends StatefulWidget {
  final List<Point> points;
  final String audioFilePath;

  GraphPage({required this.points, required this.audioFilePath});

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _currentPosition = p.inSeconds.toDouble();
      });
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(DeviceFileSource(widget.audioFilePath));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Result'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.points
                          .map((point) => FlSpot(point.x, point.y))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 1, // Make the lines thinner
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false), // Hide the points
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      VerticalLine(
                        x: _currentPosition,
                        color: Colors.red,
                        strokeWidth: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: _togglePlayPause,
              ),
              Text(_isPlaying ? 'Stop' : 'Play'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
