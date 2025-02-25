import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../fft_wrapper.dart';

class FrequencyMusicPage extends StatefulWidget {
  const FrequencyMusicPage({super.key});

  @override
  _FrequencyMusicPageState createState() => _FrequencyMusicPageState();
}

class _FrequencyMusicPageState extends State<FrequencyMusicPage> {
  List<File> musicFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  final FFTW _fftw = FFTW();
  bool isPlaying = false;
  int? playingIndex;
  double? startFrequency;
  double? endFrequency;
  double? dbLimit;
  Timer? blinkTimer;
  bool isCircleVisible = true;
  List<ChartData> spectrumData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioCapture.stop();
    blinkTimer?.cancel();
    super.dispose();
  }

  void _pickMusicFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        musicFiles.add(File(result.files.single.path!));
      });
    }
  }

  void _playMusic(BuildContext context, int index) async {
    if (startFrequency == null || endFrequency == null || dbLimit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all frequency and dB limit fields')),
      );
      return;
    }

    if (isPlaying && playingIndex == index) {
      _audioPlayer.stop();
      _audioCapture.stop();
      setState(() {
        isPlaying = false;
        playingIndex = null;
        blinkTimer?.cancel();
      });
      return;
    }

    _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(musicFiles[index].path));
    await _audioCapture.start(listener, onError, sampleRate: 44100);

    setState(() {
      isPlaying = true;
      playingIndex = index;
    });
  }

  void listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    var input = _fftw.fftw_alloc_complex(buffer.length);
    var output = _fftw.fftw_alloc_complex(buffer.length);

    for (int i = 0; i < buffer.length; i++) {
      input.elementAt(i * 2).value = buffer[i] as Pointer<Double>;
      input.elementAt(i * 2 + 1).value = 0.0 as Pointer<Double>;
    }

    var plan = _fftw.fftw_plan_dft_1d(input, output, -1, 0);
    _fftw.fftw_execute(plan);

    List<ChartData> newSpectrumData = [];
    for (int i = 0; i < buffer.length / 2; i++) {
      double frequency = i * 44100 / buffer.length;
      double amplitude =
          sqrt(output.elementAt(i * 2).value.value * output.elementAt(i * 2).value.value +
                  output.elementAt(i * 2 + 1).value.value *
                      output.elementAt(i * 2 + 1).value.value);
      newSpectrumData.add(ChartData(frequency, amplitude));
    }

    setState(() {
      spectrumData = newSpectrumData;
    });

    _fftw.fftw_destroy_plan(plan);
    _fftw.fftw_free(input);
    _fftw.fftw_free(output);
  }

  void onError(Object e) {
    print(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frequency Music Page"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: musicFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(basename(musicFiles[index].path)),
                  trailing: IconButton(
                    icon: Icon(isPlaying && playingIndex == index
                        ? Icons.stop
                        : Icons.play_arrow),
                    onPressed: () => _playMusic(context, index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Start Frequency (Hz)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      startFrequency = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: 'End Frequency (Hz)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      endFrequency = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      isCircleVisible ? Colors.red : Colors.transparent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'dB Limit'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                dbLimit = double.tryParse(value);
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Frequency (Hz)'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Amplitude'),
                ),
                series: <LineSeries<ChartData, double>>[
                  LineSeries<ChartData, double>(
                    dataSource: spectrumData,
                    xValueMapper: (ChartData data, _) => data.frequency,
                    yValueMapper: (ChartData data, _) => data.amplitude,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMusicFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ChartData {
  ChartData(this.frequency, this.amplitude);
  final double frequency;
  final double amplitude;
}
