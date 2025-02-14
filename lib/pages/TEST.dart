import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart'; // Votre helper pour la base de données
import '../models/statu.dart';

class RunStatusPage extends StatefulWidget {
  final String espIp = "http://192.168.1.112";

  const RunStatusPage({super.key});

  @override
  _RunStatusPageState createState() => _RunStatusPageState();
}

class _RunStatusPageState extends State<RunStatusPage> {
  List<Map<String, dynamic>> statusList = [];
  bool isRunning = false;
  bool isGridMode = true; // Alterner entre grille et liste
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatusesFromDatabase();
  }

  Future<void> _loadStatusesFromDatabase() async {
    final dbHelper = DBHelper();
    final List<Statu> fetchedStatuses = await dbHelper.getAllStatus();
    setState(() {
      statusList = fetchedStatuses
          .map((statu) => {
                'id': statu.statuId,
                'channels': statu.channels,
                'delayAfter': statu.delayAfter,
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize = screenWidth / 10; // Diviser la largeur par 10 colonnes

    return Scaffold(
      appBar: AppBar(
        title: const Text("Run Status"),
        actions: [
          IconButton(
            icon: Icon(isGridMode ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridMode = !isGridMode;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isGridMode
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10, // Nombre d'éléments par ligne
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: statusList.length,
                  itemBuilder: (context, index) {
                    final item = statusList[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _editDelayDialog(context, index, item['delayAfter']),
                        child: Center(
                          child: Text(
                            "ID: ${item['id']}\nDelay: ${item['delayAfter']}ms",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ReorderableListView.builder(
                  itemCount: statusList.length,
                  onReorder: _reorderStatuses,
                  itemBuilder: (context, index) {
                    return ListTile(
                      key: ValueKey(statusList[index]['id']),
                      title: Text("Statut ${statusList[index]['id']}"),
                      subtitle: Text(
                          "Délai: ${statusList[index]['delayAfter']} ms"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editDelayDialog(
                            context, index, statusList[index]['delayAfter']),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRun,
        child: Icon(isRunning ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  void _toggleRun() {
    setState(() {
      isRunning = !isRunning;
    });
  }

  void _reorderStatuses(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = statusList.removeAt(oldIndex);
      statusList.insert(newIndex, item);
    });
  }

  Future<void> _editDelayDialog(
      BuildContext context, int index, int currentDelay) async {
    TextEditingController controller =
        TextEditingController(text: currentDelay.toString());

    final newDelay = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le délai"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Délai en ms"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                Navigator.of(context).pop(value);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (newDelay != null) {
      _updateDelay(index, newDelay);
    }
  }

  void _updateDelay(int index, int newDelay) {
    setState(() {
      statusList[index]['delayAfter'] = newDelay;
    });
  }
}
