import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

List<Point> analyzeFrequency(
    String filePath, double frequencyStart, double frequencyEnd) {
  // Read the audio file and perform frequency analysis
  List<Point> points = [];
  final audioData = _readAudioFile(filePath);
  final sampleRate = 44100; // Assuming a sample rate of 44100 Hz

  for (int i = 0; i < audioData.length; i += sampleRate) {
    final segment = audioData.sublist(i, min(i + sampleRate, audioData.length));
    final dbValues =
        _calculateDbRange(segment, frequencyStart, frequencyEnd, sampleRate);
    final peakDbValue = dbValues.reduce(max);
    final timeInSeconds = i / sampleRate;
    final point = Point(timeInSeconds, peakDbValue);
    points.add(point);
    print('Point obtained: x=${point.x}, y=${point.y}');
  }

  print('Analysis complete. Total points: ${points.length}');
  return points;
}

Uint8List _readAudioFile(String filePath) {
  final file = File(filePath);
  return file.readAsBytesSync();
}

List<double> _calculateDbRange(List<int> segment, double frequencyStart,
    double frequencyEnd, int sampleRate) {
  final n = segment.length;
  final real = List<double>.filled(n, 0.0);
  final imag = List<double>.filled(n, 0.0);
  final dbValues = <double>[];

  for (double frequency = frequencyStart;
      frequency <= frequencyEnd;
      frequency += 1.0) {
    for (int i = 0; i < n; i++) {
      real[i] = segment[i] * cos(2 * pi * frequency * i / sampleRate);
      imag[i] = -segment[i] * sin(2 * pi * frequency * i / sampleRate);
    }

    final magnitude = sqrt(
        real.reduce((a, b) => a + b) * real.reduce((a, b) => a + b) +
            imag.reduce((a, b) => a + b) * imag.reduce((a, b) => a + b));

    final dbValue = 20 * log(magnitude) / ln10;
    dbValues.add(dbValue);
  }

  return dbValues;
}
