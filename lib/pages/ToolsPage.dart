import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/tools.dart';

class ToolsPage extends StatefulWidget {
  @override
  _ToolsPageState createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Tools> _toolsList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _chUsedController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTools();
  }

  // Récupérer tous les outils
  Future<void> _fetchTools() async {
    final tools = await _dbHelper.getAllTools();
    setState(() {
      _toolsList = tools;
    });
  }

  // Ajouter un outil
  Future<void> _addTool() async {
    final String name = _nameController.text;
    final int chUsed = int.tryParse(_chUsedController.text) ?? 0;

    if (name.isNotEmpty) {
      final newTool = Tools(name: name, chUsed: chUsed, label: "label");
      await _dbHelper.insertTool(newTool);
      _nameController.clear();
      _chUsedController.clear();
      _labelController.clear();
      _fetchTools();
    }
  }

  // Mettre à jour un outil
  Future<void> _updateTool(Tools tool) async {
    final updatedTool = Tools(
        toolsId: tool.toolsId,
        name: tool.name,
        chUsed: tool.chUsed + 1,
        label: tool.label);
    await _dbHelper.updateTool(updatedTool);
    _fetchTools();
  }

  // Supprimer un outil
  Future<void> _deleteTool(int id) async {
    await _dbHelper.deleteTool(id);
    _fetchTools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tools CRUD Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire pour ajouter un outil
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tool Name'),
            ),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: 'Tool label'),
            ),
            TextField(
              controller: _chUsedController,
              decoration: InputDecoration(labelText: 'Channels Used'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTool,
              child: Text('Add Tool'),
            ),
            SizedBox(height: 20),
            // Liste des outils
            Expanded(
              child: ListView.builder(
                itemCount: _toolsList.length,
                itemBuilder: (context, index) {
                  final tool = _toolsList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(tool.name),
                      subtitle: Text('Channels Used: ${tool.chUsed}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _updateTool(tool),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTool(tool.toolsId!),
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
