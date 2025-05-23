import 'package:flutter/material.dart';
import '../database/db_helper.dart'; // Remplacez par le bon chemin vers DBHelper
import '../models/model.dart'; // Remplacez par le bon chemin vers Model
import '../models/tools.dart'; // Remplacez par le bon chemin vers Tools
import 'dart:convert'; // Importer pour encoder en JSON

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  _ModelsScreenState createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<Model> models = [];

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  // Charger tous les modèles depuis la base de données
  Future<void> _loadModels() async {
    final dbHelper = DBHelper();
    List<Model> loadedModels = await dbHelper.getAllModels();
    setState(() {
      models = loadedModels;
    });
  }

  // Fonction pour afficher le JSON de tous les modèles dans la console
  void _printModelsJson() async {
    final dbHelper = DBHelper();
    List<Model> loadedModels = await dbHelper.getAllModels();
    List<Map<String, dynamic>> modelsJson =
        loadedModels.map((model) => model.toMap()).toList();
    print(jsonEncode(modelsJson)); // Afficher le JSON dans la console
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Models and Channels'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E), // Dark blue
              Color(0xFF16213E), // Darker blue
            ],
            stops: [0.5, 0.5], // Split the gradient diagonally
          ),
        ),
        child: models.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: models.length,
                itemBuilder: (context, index) {
                  final model = models[index];
                  return ListTile(
                    title: Text('Model: ${model.ref}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Number of Channels: ${model.chNumber}'),
                        for (var chTool in model.chTool)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Channel: ${chTool['channels']}'),
                              Text('Tool ID: ${chTool['tool_id']}'),
                              FutureBuilder<Tools?>(
                                future:
                                    DBHelper().getToolById(chTool['tool_id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  final tool = snapshot.data;
                                  return Text(
                                      'Tool: ${tool?.name ?? 'No Tool'}');
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _printModelsJson,
        tooltip:
            'Afficher JSON des modèles', // Appel de la fonction pour afficher le JSON
        child: const Icon(Icons.print),
      ),
    );
  }
}
