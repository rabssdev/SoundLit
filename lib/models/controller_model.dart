import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/statu.dart';
import '../models/used_light.dart';
import '../models/model.dart';

class ControllerModel extends ChangeNotifier {
  List<UsedLight> selectedUsedLights = [];
  List<Model> models = [];
  List<int> channels = List.generate(512, (_) => 0);
  List<int> previousChannels = List.generate(512, (_) => 0);
  WebSocketChannel? _channel;
  Timer? _updateTimer;
  final StreamController<List<int>> _channelUpdates =
      StreamController.broadcast();

  ControllerModel() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect('ws://192.168.1.102:3000');
    _channel!.stream.listen(
      (data) {
        try {
          Map<String, dynamic> receivedData = jsonDecode(data);
          if (receivedData.containsKey('fullState')) {
            channels = List<int>.from(receivedData['fullState']);
          } else if (receivedData.containsKey('changes')) {
            receivedData['changes'].forEach((key, value) {
              int index = int.parse(key);
              channels[index] = value;
            });
          }
          _channelUpdates.add(channels);
          notifyListeners();
        } catch (e) {
          print("Erreur lors de la réception des données WebSocket: $e");
        }
      },
      onError: (error) => print("Erreur WebSocket: $error"),
      onDone: () => print("Connexion WebSocket fermée"),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _channel?.sink.close();
    _channelUpdates.close();
    super.dispose();
  }

  void updateData(List<UsedLight>? newUsedLights, List<Model>? newModels) {
    if (newUsedLights != null) {
      selectedUsedLights = newUsedLights;
    }
    if (newModels != null) {
      models = newModels;
    }
    notifyListeners();
    _sendDMXValues();
  }

  void updateChannelValue(int index, int value) {
    if (index >= 0 && index < channels.length) {
      if (channels[index] != value) {
        channels[index] = value;
        _channelUpdates.add(channels);
        _sendDMXValues();
        notifyListeners(); // Ensure listeners are notified of the change
      }
    }
  }

  void resetChannels() {
    channels.fillRange(0, channels.length, 0);
    _channelUpdates.add(channels);
    _sendDMXValues();
  }

  void _sendDMXValues() {
    try {
      if (_channel != null) {
        Map<String, int> delta = {};
        for (int i = 0; i < channels.length; i++) {
          if (channels[i] != previousChannels[i]) {
            delta[i.toString()] = channels[i];
          }
        }
        if (delta.isNotEmpty) {
          _channel!.sink.add(jsonEncode(delta));
          previousChannels = List.from(channels);
        }
      }
    } catch (e) {
      print("Erreur d'envoi des données WebSocket: $e");
    }
  }

  Future<void> applyChannelsToStatu(Statu statu) async {
    statu.channels = List.from(channels);
    notifyListeners();
  }

  Stream<List<int>> get channelUpdates => _channelUpdates.stream;
}
