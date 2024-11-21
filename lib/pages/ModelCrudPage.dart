import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/model.dart';
class ModelCrudPage extends StatefulWidget {
  @override
  _ModelCrudPageState createState() => _ModelCrudPageState();
}

class _ModelCrudPageState extends State<ModelCrudPage> {
  final DBHelper _dbHelper = DBHelper();

  List<Model> _models = [];
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _chNumberController = TextEditingController();
  final TextEditingController _toolIdController = TextEditingController();
  final TextEditingController _channelInputController = TextEditingController();

  Map<int, List<int>> _chToolMapping = {}; // Pour stocker la relation ch -> tool

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  void _fetchModels() async {
    final models = await _dbHelper.getAllModels();
    setState(() {
      _models = models;
    });
  }

  void _addModel() async {
    if (_refController.text.isEmpty || _chNumberController.text.isEmpty) return;

    final int chNumber = int.tryParse(_chNumberController.text) ?? 0;
    final model = Model(
      ref: _refController.text,
      chNumber: chNumber,
      chTool: [],
    );
    await _dbHelper.insertModel(model);
    _refController.clear();
    _chNumberController.clear();
    _fetchModels();
  }

  void _updateModel(Model model) async {
    await _dbHelper.updateModel(model);
    _fetchModels();
  }

  void _deleteModel(int modelId) async {
    await _dbHelper.deleteModel(modelId);
    _fetchModels();
  }

  void _addChannelToTool(Model model, int toolId, List<int> channels) {
    final List<Map<String, dynamic>> updatedChTool = List.from(model.chTool);
    updatedChTool.add({'channels': channels, 'tool_id': toolId});
    final updatedModel = Model(
      modelId: model.modelId,
      ref: model.ref,
      chNumber: model.chNumber,
      chTool: updatedChTool,
    );
    _updateModel(updatedModel);
  }

  void _openAssignToolDialog(Model model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Affecter un outil au modèle ${model.ref}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _toolIdController,
                decoration: InputDecoration(labelText: 'Tool ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _channelInputController,
                decoration: InputDecoration(
                  labelText: 'Canaux (séparés par des virgules)',
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final int toolId =
                    int.tryParse(_toolIdController.text.trim()) ?? 0;
                final List<int> channels = _channelInputController.text
                    .split(',')
                    .map((e) => int.tryParse(e.trim()) ?? 0)
                    .toList();

                _addChannelToTool(model, toolId, channels);
                _toolIdController.clear();
                _channelInputController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Modèles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _refController,
                  decoration: InputDecoration(labelText: 'Référence du modèle'),
                ),
                TextField(
                  controller: _chNumberController,
                  decoration:
                      InputDecoration(labelText: 'Nombre de canaux disponibles'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addModel,
                  child: Text('Ajouter un modèle'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _models.length,
              itemBuilder: (context, index) {
                final model = _models[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Réf : ${model.ref}'),
                    subtitle: Text(
                        'Canaux : ${model.chNumber} | Tools assignés : ${model.chTool.length}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteModel(model.modelId!),
                    ),
                    onTap: () => _openAssignToolDialog(model),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
