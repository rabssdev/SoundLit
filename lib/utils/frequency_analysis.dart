import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

Future<List<Point>> analyzeFrequency(String filePath) async {
  List<Point> points = [];
  final audioData = _readAudioFile(filePath);
  final sampleRate = 44100; // Assuming a sample rate of 44100 Hz
  final fft = FFT(1024); // Use a segment size of 1024, which is a power of two

  for (int i = 0; i < audioData.length; i += 1024) {
    final segment = _getSegment(audioData, i, 1024);
    final dbValue = _calculateDb(segment, sampleRate, fft);
    final timeInSeconds = i / sampleRate;
    final point = Point(timeInSeconds, dbValue);
    points.add(point);
  }

  return points;
}

Future<double> getAudioDuration(String filePath) async {
  final audioPlayer = AudioPlayer();
  await audioPlayer.setSourceDeviceFile(filePath);
  final duration = await audioPlayer.getDuration();
  return duration?.inSeconds.toDouble() ?? 0.0;
}

Uint8List _readAudioFile(String filePath) {
  final file = File(filePath);
  return file.readAsBytesSync();
}

List<double> _getSegment(Uint8List audioData, int start, int length) {
  final segment = List<double>.filled(length, 0.0);
  for (int i = 0; i < length && start + i < audioData.length; i++) {
    segment[i] = audioData[start + i].toDouble();
  }
  return segment;
}

double _calculateDb(List<double> segment, int sampleRate, FFT fft) {
  final n = segment.length;
  final windowedSegment = _applyHannWindow(segment);
  final spectrum = fft.realFft(windowedSegment);
  final magnitude = spectrum.map((c) => c.abs().x).reduce(max);

  return 20 * log(magnitude) / ln10;
}

List<double> _applyHannWindow(List<double> segment) {
  final n = segment.length;
  final windowedSegment = List<double>.filled(n, 0.0);

  for (int i = 0; i < n; i++) {
    windowedSegment[i] = segment[i] * 0.5 * (1 - cos(2 * pi * i / (n - 1)));
  }

  return windowedSegment;
}
