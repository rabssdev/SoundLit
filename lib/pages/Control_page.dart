import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/custom_slider.dart';
import '../models/statu.dart';
import '../database/db_helper.dart';
import '../models/model.dart';
import '../models/used_light.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  ControlPageState createState() => ControlPageState();
}

class ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SliderScreen(),
    );
  }
}

class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  _SliderScreenState createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120, // Fixe une hauteur pour le contenu
          child: HorizontalStatuManager(),
        ),
        Expanded(
          child: Row(
            children: [
              ControlWidget(),
              SizedBox(
                width: 120, // Fixe une hauteur pour le contenu
                child: UsedLightListScreen(),
              ),
              // UsedLightListScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

class UsedLightListWidget extends StatefulWidget {
  const UsedLightListWidget({super.key});

  @override
  State<UsedLightListWidget> createState() => _UsedLightListWidgetState();
}

class _UsedLightListWidgetState extends State<UsedLightListWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class StateWidget extends StatefulWidget {
  const StateWidget({super.key});

  @override
  State<StateWidget> createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ControlWidget extends StatefulWidget {
  const ControlWidget({super.key});

  @override
  State<ControlWidget> createState() => _ControlWidgetState();
}

class _ControlWidgetState extends State<ControlWidget> {
  @override
  Widget build(BuildContext context) {
    // Calcul du nombre total de pages nécessaires

    return const Expanded(
      child: Text("Hello"),
    );
  }
}

class HorizontalStatuManager extends StatefulWidget {
  @override
  _HorizontalStatuManagerState createState() => _HorizontalStatuManagerState();
}

class _HorizontalStatuManagerState extends State<HorizontalStatuManager> {
  final DBHelper _dbHelper = DBHelper();
  List<Statu> _status = [];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  /// Récupère tous les statuts de la base de données.
  Future<void> _fetchStatus() async {
    final status = await _dbHelper.getAllStatus();
    setState(() {
      _status = status;
    });
  }

  /// Ajoute un nouveau statut avec les paramètres par défaut.
  Future<void> _addStatu() async {
    final newStatu = Statu(
      channels: List.filled(512, 0),
      activated: false,
      delayAfter: 0,
    );

    await _dbHelper.insertStatu(newStatu);
    _fetchStatus();
  }

  /// Supprime le dernier statut dans la liste.
  Future<void> _removeLastStatu() async {
    if (_status.isNotEmpty) {
      final lastStatuId = _status.last.statuId!;
      await _dbHelper.deleteStatu(lastStatuId);
      _fetchStatus();
    }
  }

  /// Sélectionne un statut spécifique et désélectionne les autres.
  Future<void> _selectStatu(int selectedIndex) async {
    for (int i = 0; i < _status.length; i++) {
      _status[i].activated = i == selectedIndex;
      await _dbHelper.updateStatu(_status[i]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _status.isEmpty
              ? Center(
                  child: Text(
                    "No status available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _status.length,
                  itemBuilder: (context, index) {
                    final statu = _status[index];
                    return GestureDetector(
                      onTap: () => _selectStatu(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              statu.activated ? Colors.white : Colors.purple,
                          child: Text(
                            '${index + 1}', // Numéro du statut
                            style: TextStyle(
                              color:
                                  statu.activated ? Colors.black : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(width: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _addStatu,
              icon: Icon(Icons.add),
              color: Colors.green,
              iconSize: 40,
            ),
            SizedBox(width: 20),
            IconButton(
              onPressed: _removeLastStatu,
              icon: Icon(Icons.remove),
              color: Colors.red,
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }
}

class UsedLightListScreen extends StatefulWidget {
  @override
  _UsedLightListScreenState createState() => _UsedLightListScreenState();
}

class _UsedLightListScreenState extends State<UsedLightListScreen> {
  List<UsedLight> usedLights = [];
  Map<int, Color> modelColors = {}; // Map des couleurs par modèle
  Set<int> selectedUsedLightIds = {}; // Ensemble des IDs sélectionnés
  late DBHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    // Charge les UsedLight et les modèles
    final lights = await dbHelper.getAllUsedLights();
    final models = await dbHelper.getAllModels();

    // Associe chaque modèle à une couleur unique
    final uniqueColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.red.shade100,
      Colors.yellow.shade100,
    ];

    int colorIndex = 0;
    Map<int, Color> tempModelColors = {};
    for (var model in models) {
      tempModelColors[model.modelId!] =
          uniqueColors[colorIndex % uniqueColors.length];
      colorIndex++;
    }

    setState(() {
      usedLights = lights;
      modelColors = tempModelColors;
    });
  }

  void _toggleSelection(UsedLight usedLight) {
    final modelId = usedLight.modelId;

    // Vérifie si les UsedLight sélectionnés appartiennent au même modèle
    bool canSelect = selectedUsedLightIds.isEmpty ||
        usedLights
            .where((light) => selectedUsedLightIds.contains(light.usedLightId))
            .every((light) => light.modelId == modelId);

    if (canSelect) {
      setState(() {
        if (selectedUsedLightIds.contains(usedLight.usedLightId)) {
          selectedUsedLightIds.remove(usedLight.usedLightId);
        } else {
          selectedUsedLightIds.add(usedLight.usedLightId!);
        }
      });
    } else {
      // Optionnel : Afficher une alerte si la sélection est invalide
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Vous ne pouvez sélectionner que des éléments avec le même modèle.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView.builder(
        itemCount: usedLights.length,
        itemBuilder: (context, index) {
          final light = usedLights[index];
          final modelId = light.modelId;
          final color = modelColors[modelId] ?? Colors.grey.shade200;
          final isSelected = selectedUsedLightIds.contains(light.usedLightId);

          return GestureDetector(
            onTap: () => _toggleSelection(light),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : color,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: isSelected ? 2 : 0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Used Light ID: ${light.usedLightId}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Model ID: $modelId'),
                  Text('Activated: ${light.activated ? "Yes" : "No"}'),
                  Text('Channels: ${light.channels.join(", ")}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
