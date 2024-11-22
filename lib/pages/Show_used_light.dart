import 'package:flutter/material.dart';
import '../models/model.dart'; // Modèle représentant la structure des modèles
import '../models/used_light.dart'; // Modèle représentant la structure des used lights
import '../database/db_helper.dart'; // Votre helper de base de données pour accéder aux données

class UsedLightsPage extends StatefulWidget {
  @override
  _UsedLightsPageState createState() => _UsedLightsPageState();
}

class _UsedLightsPageState extends State<UsedLightsPage> {
  final DBHelper dbHelper = DBHelper(); // Instance de votre helper DB

  // Liste des modèles récupérés depuis la base de données
  List<Model> models = [];

  // Liste des used lights récupérées depuis la base de données
  List<UsedLight> usedLights = [];

  @override
  void initState() {
    super.initState();
    loadInitialData(); // Charger les données initiales (models et usedLights)
  }

  Future<void> loadInitialData() async {
    // Charger les modèles et les used lights depuis la base de données
    List<Model> fetchedModels = await dbHelper.getAllModels();
    List<UsedLight> fetchedUsedLights = await dbHelper.getAllUsedLights();

    setState(() {
      models = fetchedModels;
      usedLights = fetchedUsedLights;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Used Lights"),
      ),
      body: models.isEmpty || usedLights.isEmpty
          ? Center(child: CircularProgressIndicator()) // Affiche un loader pendant le chargement des données
          : ListView.builder(
              itemCount: usedLights.length,
              itemBuilder: (context, index) {
                var usedLight = usedLights[index];

                // Trouver le modèle associé à la Used Light
                var associatedModel = models.firstWhere(
                    (model) => model.modelId == usedLight.modelId,
                    orElse: () => Model(
                          modelId: -1,
                          ref: "Non défini",
                          chNumber: 0,
                          chTool: [], // Fournir une liste vide pour chTool
                        ));

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
                              "Used Light ID: ${usedLight.usedLightId}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Model: ${associatedModel.ref}", // Affiche le modèle associé
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
