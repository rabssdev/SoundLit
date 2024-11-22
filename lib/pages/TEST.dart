import 'package:flutter/material.dart';
import 'dart:math'; // Pour les couleurs aléatoires

// Modèles de données
class Statu {
  final int? statuId;
  final List<int> channels;
  final bool activated;
  final int delayAfter;

  Statu({
    this.statuId,
    required this.channels,
    required this.activated,
    required this.delayAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'statu_id': statuId,
      'channels': channels.join(','),
      'activated': activated ? 1 : 0,
      'delay_after': delayAfter,
    };
  }

  factory Statu.fromMap(Map<String, dynamic> map) {
    return Statu(
      statuId: map['statu_id'],
      channels: (map['channels'] as String).split(',').map(int.parse).toList(),
      activated: map['activated'] == 1,
      delayAfter: map['delay_after'],
    );
  }
}

class UsedLight {
  final int id;
  final int modelId;
  final List<int> channels;

  UsedLight({required this.id, required this.modelId, required this.channels});
}

class Model {
  final int id;
  final int chNumber;

  Model({required this.id, required this.chNumber});
}

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Simulation des données
  List<Statu> statuses = [
    Statu(statuId: 1, channels: List.filled(512, 0), activated: true, delayAfter: 0),
    Statu(statuId: 2, channels: List.filled(512, 0), activated: false, delayAfter: 0),
  ];

  List<UsedLight> usedLights = [
    UsedLight(id: 1, modelId: 1, channels: [5, 6, 7]),
    UsedLight(id: 2, modelId: 1, channels: [12, 13, 14, 15]),
    UsedLight(id: 3, modelId: 2, channels: [20, 21, 22]),
  ];

  List<Model> models = [
    Model(id: 1, chNumber: 7),
    Model(id: 2, chNumber: 3),
  ];

  int? selectedStatuId;
  List<int> selectedUsedLights = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Widget de statut (Scroll horizontal)
          Expanded(
            flex: 2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final statu = statuses[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      statuses = statuses.map((s) {
                        return s.copyWith(activated: s.statuId == statu.statuId);
                      }).toList();
                      selectedStatuId = statu.statuId;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statu.activated ? Colors.green : Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Text(
                        "${statu.statuId}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Widget pour les UsedLights (Scroll vertical)
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: usedLights.length,
              itemBuilder: (context, index) {
                final light = usedLights[index];
                final model = models.firstWhere((m) => m.id == light.modelId);

                return GestureDetector(
                  onTap: () {
                    if (selectedUsedLights.isEmpty ||
                        selectedUsedLights.every((id) =>
                            usedLights.firstWhere((l) => l.id == id).modelId ==
                            light.modelId)) {
                      setState(() {
                        if (selectedUsedLights.contains(light.id)) {
                          selectedUsedLights.remove(light.id);
                        } else {
                          selectedUsedLights.add(light.id);
                        }
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedUsedLights.contains(light.id)
                          ? Colors.black
                          : Colors.primaries[Random().nextInt(Colors.primaries.length)],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Light ${light.id}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Widget de contrôle
          Expanded(
            flex: 4,
            child: selectedUsedLights.isEmpty
                ? Center(
                    child: Text(
                      "Select a Used Light",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedUsedLights.length,
                    itemBuilder: (context, index) {
                      final light = usedLights
                          .firstWhere((l) => l.id == selectedUsedLights[index]);

                      return Column(
                        children: light.channels.map((channel) {
                          return Slider(
                            value: statuses
                                .firstWhere((s) => s.statuId == selectedStatuId)
                                .channels[channel]
                                .toDouble(),
                            min: 0,
                            max: 255,
                            onChanged: (value) {
                              setState(() {
                                statuses
                                    .firstWhere((s) => s.statuId == selectedStatuId)
                                    .channels[channel] = value.toInt();
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

extension on Statu {
  Statu copyWith({
    int? statuId,
    List<int>? channels,
    bool? activated,
    int? delayAfter,
  }) {
    return Statu(
      statuId: statuId ?? this.statuId,
      channels: channels ?? this.channels,
      activated: activated ?? this.activated,
      delayAfter: delayAfter ?? this.delayAfter,
    );
  }
}
