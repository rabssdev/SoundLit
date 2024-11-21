import 'package:flutter/material.dart';
import '../database/db_helper.dart'; // Chemin du fichier DBHelper
import '../models/used_light.dart';
import '../models/model.dart';


class UsedLightPage extends StatefulWidget {
  @override
  _UsedLightPageState createState() => _UsedLightPageState();
}

class _UsedLightPageState extends State<UsedLightPage> {
  final DBHelper _dbHelper = DBHelper();
  List<UsedLight> _usedLights = [];
  List<Model> _models = [];
  int? _selectedModelId;
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Récupérer les données de la base
    final usedLights = await _dbHelper.getAllUsedLights();
    final models = await _dbHelper.getAllModels();

    setState(() {
      _usedLights = usedLights;
      _models = models;
      if (_models.isNotEmpty) {
        _selectedModelId = _models.first.modelId;
      }
    });
  }

  Future<void> _addUsedLight() async {
    if (_selectedModelId != null) {
      final newUsedLight = UsedLight(
        modelId: _selectedModelId!,
        activated: _activated,
      );

      await _dbHelper.insertUsedLight(newUsedLight);
      await _fetchData(); // Mettre à jour l'interface
    }
  }

  Future<void> _deleteUsedLight(int id) async {
    await _dbHelper.deleteUsedLight(id);
    await _fetchData(); // Mettre à jour l'interface
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Used Lights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Formulaire pour ajouter un UsedLight
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter un Used Light',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Dropdown pour sélectionner un Model
                      DropdownButton<int>(
                        value: _selectedModelId,
                        items: _models
                            .map(
                              (model) => DropdownMenuItem<int>(
                                value: model.modelId,
                                child: Text(model.ref),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedModelId = value;
                          });
                        },
                        isExpanded: true,
                        hint: Text('Sélectionnez un modèle'),
                      ),
                      SizedBox(height: 16),
                      // Checkbox pour l'état activé
                      Row(
                        children: [
                          Checkbox(
                            value: _activated,
                            onChanged: (value) {
                              setState(() {
                                _activated = value ?? false;
                              });
                            },
                          ),
                          Text('Activé'),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Bouton pour ajouter
                      ElevatedButton(
                        onPressed: _addUsedLight,
                        child: Text('Ajouter'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Liste des Used Lights
              _usedLights.isEmpty
                  ? Center(child: Text('Aucun Used Light disponible.'))
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _usedLights.length,
                      itemBuilder: (context, index) {
                        final usedLight = _usedLights[index];
                        final model = _models.firstWhere(
                          (model) => model.modelId == usedLight.modelId,
                          orElse: () => Model(
                            modelId: 0,
                            ref: 'Modèle inconnu',
                            chNumber: 0,
                            chTool: [],
                          ),
                        );

                        return Card(
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('Model: ${model.ref}'),
                            subtitle: Text('Activé: ${usedLight.activated ? "Oui" : "Non"}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUsedLight(usedLight.usedLightId!),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
