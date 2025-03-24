import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';

class RecorderPage extends StatefulWidget {
  const RecorderPage({Key? key}) : super(key: key);

  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  List<FlSpot> _frequencyData = [];
  List<FlSpot> _filteredFrequencyData = [];
  final FFT _fft = FFT(1024);
  final List<double> _samples = List.filled(1024, 0.0);
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>();
  List<List<double>> _spectrogramData = [];
  final int _maxSpectrogramLength = 100;
  final double _decibelThreshold = 0.0; // Adjusted threshold in decibels

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _audioStreamController.stream.listen(_processAudioData);
  }

  Future<void> _initializeRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
    super.dispose();
  }

  void _startRecording() async {
    try {
      await _recorder.startRecorder(
        toStream: _audioStreamController.sink,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  void _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping recorder: $e');
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _processAudioData(Uint8List data) {
    final List<double> audioSamples = data.map((e) => e.toDouble()).toList();

    // Ensure we only process the available data length
    int length = min(audioSamples.length, _samples.length);

    // Application d'une fenêtre Hann pour lisser la FFT
    for (int i = 0; i < length; i++) {
      _samples[i] =
          audioSamples[i] * (0.5 * (1 - cos(2 * pi * i / _samples.length)));
    }

    final Float64x2List spectrum = _fft.realFft(_samples);
    final List<FlSpot> newData = [];

    for (int i = 1; i < spectrum.length ~/ 2; i++) {
      double frequency = i * 44100 / 1024; // Convertir en Hz
      double magnitude = spectrum[i].x.abs(); // Module de la FFT
      double decibels = 20 * log(magnitude + 1e-6); // Convertir en dB

      // Debug print for raw intensity data
      print(
          'Frequency: $frequency Hz, Magnitude: $magnitude, Decibels: $decibels');

      if (frequency >= 30 &&
          frequency <= 4000 &&
          decibels >= _decibelThreshold) {
        newData.add(FlSpot(frequency, decibels));
      }
    }

    setState(() {
      _frequencyData = newData;
      _filteredFrequencyData =
          newData.where((spot) => spot.x >= 100 && spot.x <= 2000).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorder'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? 'Stop' : 'Record'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toStringAsFixed(0));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0, // Fixed min value for y-axis
                    maxY: 400, // Fixed max value for y-axis
                    lineBarsData: [
                      LineChartBarData(
                        spots: _frequencyData,
                        isCurved: true,
                        color: Colors.purpleAccent,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _filteredFrequencyData.map((spot) {
                  return Text(
                      'Frequency: ${spot.x.toStringAsFixed(2)} Hz, Intensity: ${spot.y.toStringAsFixed(2)} dB');
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpectrogramPainter extends CustomPainter {
  final List<List<double>> spectrogramData;

  SpectrogramPainter(this.spectrogramData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double columnWidth = size.width / spectrogramData.length;
    final double rowHeight = size.height / 1024;

    for (int x = 0; x < spectrogramData.length; x++) {
      for (int y = 0; y < spectrogramData[x].length; y++) {
        double intensity = spectrogramData[x][y];
        paint.color = Color.lerp(Colors.black, Colors.blue, intensity / 255)!;
        canvas.drawRect(
          Rect.fromLTWH(x * columnWidth, y * rowHeight, columnWidth, rowHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
