import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/model.dart';
import 'package:provider/provider.dart';
import '../models/tools.dart';

class AddModelPage extends StatefulWidget {
  const AddModelPage({super.key});

  @override
  _AddModelPageState createState() => _AddModelPageState();
}

class _AddModelPageState extends State<AddModelPage> {
  final DBHelper dbHelper = DBHelper();
  List<Model> models = []; // Liste des modèles récupérés depuis la base de données

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  // Récupérer tous les modèles depuis la base de données
  Future<void> _fetchModels() async {
    final allModels = await dbHelper.getAllModels();
    setState(() {
      models = allModels;
    });
  }

  // Ajouter un modèle dans la base de données
  Future<void> addModel() async {
    final newModel = Model(
      ref: "Hello",
      chNumber: 4,
      chTool: [
        {"channels": [1, 2], "tool_id": 2},
        {"channels": [3, 4], "tool_id": 1},
      ],
    );

    await dbHelper.insertModel(newModel); // Insertion dans la base de données
    _fetchModels(); // Rafraîchir la liste des modèles
  }

  // Récupérer le nom de l'outil pour chaque channel
  Future<String> _getToolName(int toolId) async {
    final tool = await dbHelper.getAllTools(); // Récupérer tous les outils
    final matchingTool = tool.firstWhere(
      (t) => t.toolsId == toolId,
      orElse: () => Tools(name: "Unknown", chUsed: 0,label: "label"),
    );
    return matchingTool.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Modèle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: addModel,
              child: const Text("Ajouter un modèle"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: models.length,
                itemBuilder: (context, index) {
                  final model = models[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text("Modèle ${model.ref}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nombre de canaux : ${model.chNumber}"),
                          FutureBuilder<List<String>>(
                            future: Future.wait(model.chTool.map((tool) async {
                              final toolName = await _getToolName(tool['tool_id']);
                              return "Channels: ${tool['channels']} - Tool: $toolName";
                            })),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text("Chargement des outils...");
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!
                                    .map((e) => Text(e))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
