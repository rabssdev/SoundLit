import 'package:flutter/material.dart';
import 'package:flutter_application_3/database/db_helper.dart';
import 'package:flutter_application_3/models/light.dart';

class AddLightPage extends StatefulWidget {
  const AddLightPage({super.key});

  @override
  State<AddLightPage> createState() => _AddLightPageState();
}

class _AddLightPageState extends State<AddLightPage> {
  List<Light> lights = [];

  @override
  void initState() {
    super.initState();
    fetchLights();
  }

  Future<void> fetchLights() async {
    final db = await DBHelper().database;
    final result = await db.query('Light');
    setState(() {
      lights = result.map((map) => Light.fromMap(map)).toList();
    });
  }

  Future<void> addLight(Light light) async {
    await DBHelper().insertLight(light);
    fetchLights(); // Recharge la liste après l'ajout
  }

  Future<void> deleteLight(int number) async {
  final db = await DBHelper().database;
  await db.delete('Light', where: 'number = ?', whereArgs: [number]);
  fetchLights(); // Recharge la liste après suppression
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lights')),
      body: ListView.builder(
        itemCount: lights.length,
        itemBuilder: (context, index) {
          final light = lights[index];
          return ListTile(
            title: Text(light.name),
            subtitle: Text('Channel: ${light.channelNumber}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: light.state,
                  onChanged: (value) {
                    setState(() {
                      lights[index] = Light(
                        name: light.name,
                        number: light.number,
                        state: value,
                        channelNumber: light.channelNumber,
                      );
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await deleteLight(light.number);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addLight(
            Light(
              name: 'Light ${lights.length + 1}',
              number: lights.length + 1,
              state: true,
              channelNumber: 100 + lights.length + 1,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

