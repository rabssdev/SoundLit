import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tools.dart';
import '../models/model.dart';
import '../database/db_helper.dart';

class AddModelPage extends StatefulWidget {
  const AddModelPage({super.key});

  @override
  _AddModelPageState createState() => _AddModelPageState();
}

class _AddModelPageState extends State<AddModelPage> {
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _chNumberController = TextEditingController();
  int? chNumber;
  List<int> selectedChannels = [];
  Map<String, dynamic> groupedToolMap = {}; // Map regroupant les canaux, tool_id et label
  bool showSuccessMessage = false;

  List<Tools> tools = [];
  Tools? selectedTool;
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTools();
  }

  Future<void> _fetchTools() async {
    final db = DBHelper();
    final toolList = await db.getAllTools();
    setState(() {
      tools = toolList;
    });
  }

  void _validateToolSelection() {
    if (selectedChannels.length == (selectedTool?.chUsed ?? 0)) {
      final key = '${selectedTool?.toolsId}-${_labelController.text}';
      if (!groupedToolMap.containsKey(key)) {
        groupedToolMap[key] = {
          'channels': [],
          'tool_id': selectedTool?.toolsId,
          'label': _labelController.text,
        };
      }
      groupedToolMap[key]['channels'].addAll(selectedChannels);

      setState(() {
        selectedChannels.clear();
        _labelController.clear();
        selectedTool = null;
      });
    }
  }

  Future<void> _saveModel() async {
    if (_refController.text.isEmpty || chNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final db = DBHelper();
    final model = Model(
      ref: _refController.text,
      chNumber: chNumber!,
      chTool: groupedToolMap.values.map((entry) {
        return {
          'channels': entry['channels'],
          'tool_id': entry['tool_id'],
          'label': entry['label'],
        };
      }).toList(),
    );
    // print(model.toMap());
    await db.insertModel(model);

    setState(() {
      showSuccessMessage = true;
    });

    Timer(const Duration(seconds: 1), () {
      setState(() {
        showSuccessMessage = false;
        _refController.clear();
        _chNumberController.clear();
        chNumber = null;
        selectedChannels.clear();
        groupedToolMap.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un modèle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showSuccessMessage
            ? const Center(
                child: Text(
                  'Succès',
                  style: TextStyle(color: Colors.green, fontSize: 24),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _refController,
                            decoration: const InputDecoration(
                              labelText: 'Référence du modèle',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _chNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de canaux',
                            ),
                            onChanged: (value) {
                              setState(() {
                                chNumber = int.tryParse(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (chNumber != null)
                      SizedBox(
                        height: 150,
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                          ),
                          itemCount: chNumber!,
                          itemBuilder: (context, index) {
                            final channelNumber = index + 1;
                            final isSelected = selectedChannels.contains(channelNumber);
                            final isValidated = groupedToolMap.values.any(
                                (entry) => entry['channels'].contains(channelNumber));

                            return GestureDetector(
                              onTap: () {
                                if (!isValidated &&
                                    selectedChannels.length <
                                        (selectedTool?.chUsed ?? 1)) {
                                  setState(() {
                                    selectedChannels.add(channelNumber);
                                  });
                                }
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isValidated
                                      ? Colors.white
                                      : (isSelected ? Colors.blue : Colors.green),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  channelNumber.toString(),
                                  style: TextStyle(
                                    color: isValidated
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<Tools>(
                            value: selectedTool,
                            hint: const Text('Sélectionnez un outil'),
                            items: tools.map((tool) {
                              return DropdownMenuItem<Tools>(
                                value: tool,
                                child: Text(tool.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTool = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _labelController,
                            decoration: const InputDecoration(
                              labelText: 'Label',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: selectedTool == null ||
                                  selectedChannels.length !=
                                      (selectedTool?.chUsed ?? 0)
                              ? null
                              : _validateToolSelection,
                          child: const Text('Valider'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedChannels.clear();
                              _labelController.clear();
                              selectedTool = null;
                            });
                          },
                          child: const Text('Retour'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveModel,
                        child: const Text('Enregistrer le modèle'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
