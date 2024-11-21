import 'package:flutter/material.dart';
import '../database/db_helper.dart'; // Assurez-vous que cette classe gère les opérations pour `State`
import '../models/statu.dart';

class StatuPage extends StatefulWidget {
  const StatuPage({super.key});

  @override
  State<StatuPage> createState() => _StatuPageState();
}

class _StatuPageState extends State<StatuPage> {
final DBHelper _dbHelper = DBHelper();

  List<Statu> _status = [];
  List<int> _availableChannels = [
    1,
    2,
    3,
    4,
    5
  ]; // Exemple de canaux disponibles
  List<int> _selectedChannels = [];
  bool _activated = false;
  int _delayAfter = 0;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final status = await _dbHelper.getAllStatus(); // Récupérer tous les états
    setState(() {
      _status = status;
    });
  }

  Future<void> _addStatu() async {
    if (_selectedChannels.isNotEmpty) {
      final newStatu = Statu(
        channels: _selectedChannels,
        activated: _activated,
        delayAfter: _delayAfter,
      );

      await _dbHelper.insertStatu(newStatu);
      await _fetchStatus();
    }
  }

  Future<void> _deleteStatu(int id) async {
    await _dbHelper.deleteStatu(id);
    await _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Status'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Formulaire d'ajout de Statu
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter un Statu',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Liste déroulante pour sélectionner les canaux
                      Text('Sélectionnez les canaux :'),
                      Wrap(
                        spacing: 8.0,
                        children: _availableChannels.map((channel) {
                          final isSelected =
                              _selectedChannels.contains(channel);
                          return FilterChip(
                            label: Text('Canal $channel'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedChannels.add(channel);
                                } else {
                                  _selectedChannels.remove(channel);
                                }
                              });
                            },
                          );
                        }).toList(),
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
                      // Champ pour définir le délai
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Délai après (en secondes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _delayAfter = int.tryParse(value) ?? 0;
                        },
                      ),
                      SizedBox(height: 16),
                      // Bouton pour ajouter
                      ElevatedButton(
                        onPressed: _addStatu,
                        child: Text('Ajouter'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Liste des Status
              _status.isEmpty
                  ? Center(child: Text('Aucun Statu disponible.'))
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _status.length,
                      itemBuilder: (context, index) {
                        final statu = _status[index];
                        return Card(
                          elevation: 4.0,
                          child: ListTile(
                            title:
                                Text('Canaux : ${statu.channels.join(", ")}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Activé : ${statu.activated ? "Oui" : "Non"}'),
                                Text(
                                    'Délai après : ${statu.delayAfter} secondes'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStatu(statu.statuId!),
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



