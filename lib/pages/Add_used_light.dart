import 'package:flutter/material.dart';
import '../models/model.dart';
import '../models/used_light.dart';
import '../database/db_helper.dart';
import 'package:collection/collection.dart';

class AddUsedLightPage extends StatefulWidget {
  @override
  _AddUsedLightPageState createState() => _AddUsedLightPageState();
}

class _AddUsedLightPageState extends State<AddUsedLightPage> {
  final DBHelper dbHelper = DBHelper();

  // Liste des modèles disponibles (récupérés depuis la base de données)
  List<Model> models = [];

  // Liste des UsedLights (récupérés depuis la base de données)
  List<UsedLight> usedLights = [];

  // Variable pour suivre le canal en cours
  int currentChannel = 1;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    // Récupérer les modèles et les lumières utilisées depuis la base de données
    List<Model> fetchedModels = await dbHelper.getAllModels();
    List<UsedLight> fetchedUsedLights = await dbHelper.getAllUsedLights();

    setState(() {
      models = fetchedModels;
      usedLights = fetchedUsedLights;

      // Met à jour `currentChannel` en fonction des lumières utilisées
      if (usedLights.isNotEmpty) {
        currentChannel = usedLights.last.modelId + 1;
      }
    });
  }

  Future<void> addUsedLight() async {
    final newUsedLight = UsedLight(
      modelId: -1, // -1 signifie "non défini" pour le modèle
      activated: false,
    );

    final id = await dbHelper.insertUsedLight(newUsedLight);

    setState(() {
      usedLights.add(newUsedLight.copyWith(usedLightId: id));
    });
  }

  Future<void> updateUsedLight(int index, Model? model) async {
    if (model == null) return;

    setState(() {
      int channels = model.chNumber;
      if (model.modelId != null) {
        usedLights[index] = usedLights[index].copyWith(
          modelId: model.modelId!,
          activated: true,
        );
      }

      // Calculer le prochain canal disponible
      currentChannel = usedLights.fold<int>(
        1,
        (prev, light) =>
            prev +
            models
                .firstWhere((model) => model.modelId == light.modelId)
                .chNumber,
      );
    });

    await dbHelper.updateUsedLight(usedLights[index]);
  }

  Future<void> deleteUsedLight(int index) async {
    int usedLightId = usedLights[index].usedLightId!;
    await dbHelper.deleteUsedLight(usedLightId);

    setState(() {
      usedLights.removeAt(index);

      // Recalculer le canal en cours
      currentChannel = usedLights.isEmpty
          ? 1
          : usedLights.fold<int>(
              1,
              (prev, light) =>
                  prev +
                  models
                      .firstWhere((model) => model.modelId == light.modelId)
                      .chNumber,
            );
    });
  }

  Future<void> saveUsedLights() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Enregistrement des lumières utilisées effectué."),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Used Light"),
        actions: [
          TextButton(
            onPressed: saveUsedLights,
            child: Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: usedLights.length,
              itemBuilder: (context, index) {
                var usedLight = usedLights[index];

                // Calculer les canaux pour cet index
                int beginChannel = 1; // Canal de début par défaut
                for (int i = 0; i < index; i++) {
                  var previousModel = models.firstWhereOrNull(
                    (model) => model.modelId == usedLights[i].modelId,
                  );
                  if (previousModel != null) {
                    beginChannel += previousModel.chNumber;
                  }
                }

                int endChannel =
                    beginChannel - 1; // Si aucun modèle sélectionné
                var selectedModel = models.firstWhereOrNull(
                  (model) => model.modelId == usedLight.modelId,
                );
                if (selectedModel != null) {
                  endChannel = beginChannel + selectedModel.chNumber - 1;
                }

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BEGIN CHANNEL: $beginChannel",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "END CHANNEL: $endChannel",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        DropdownButton<Model>(
                          value: models.firstWhereOrNull(
                              (model) => model.modelId == usedLight.modelId),
                          hint: Text("Select Model"),
                          items: models.map((model) {
                            return DropdownMenuItem<Model>(
                              value: model,
                              child: Text(model.ref),
                            );
                          }).toList(),
                          onChanged: (Model? value) {
                            if (value != null) {
                              updateUsedLight(index, value);
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () => deleteUsedLight(index),
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: addUsedLight,
                icon: Icon(Icons.add_circle, color: Colors.green, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
