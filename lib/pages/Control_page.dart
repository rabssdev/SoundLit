import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/custom_slider.dart';
import 'package:provider/provider.dart';

import '../models/statu.dart';
import '../database/db_helper.dart';
import '../models/model.dart';
import '../models/used_light.dart';
import '../models/tools.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

class ControllerModel extends ChangeNotifier {
  List<UsedLight> selectedUsedLights = [
    UsedLight(
      usedLightId: 1,
      modelId: 1,
      activated: true,
      channels: [1, 2, 3, 4],
    ),
    UsedLight(
      usedLightId: 1,
      modelId: 1,
      activated: true,
      channels: [1, 2, 3, 4],
    ),
    UsedLight(
      usedLightId: 1,
      modelId: 1,
      activated: true,
      channels: [1, 2, 3, 4],
    ),
    UsedLight(
      usedLightId: 1,
      modelId: 1,
      activated: true,
      channels: [1, 2, 3, 4],
    ),
  ];
  List<Model> models = [
    Model(
      modelId: 1,
      ref: 'Model001',
      chNumber: 3,
      chTool: [
        {
          'channels': [1, 2, 3],
          'tool_id': 1,
          'label': "pallete"
        },
        {
          'channels': [4],
          'tool_id': 2,
          'label': "slider test"
        }
      ],
    ),
    Model(
      modelId: 2,
      ref: 'Model002',
      chNumber: 3,
      chTool: [
        {
          'channels': [1, 2, 3],
          'tool_id': 2,
          'label': "slider tsy vri"
        },
      ],
    ),
  ];

  void updateData(List<UsedLight>? newUsedLights, List<Model>? newModels) {
    if (newUsedLights != null) {
      selectedUsedLights = newUsedLights;
    }
    if (newModels != null) {
      models = newModels;
    }
    notifyListeners();
  }
}

List<UsedLight> selectedUsedLights = [
  UsedLight(
    usedLightId: 1,
    modelId: 1,
    activated: true,
    channels: [1, 2, 3, 4],
  ),
  UsedLight(
    usedLightId: 1,
    modelId: 1,
    activated: true,
    channels: [1, 2, 3, 4],
  ),
  UsedLight(
    usedLightId: 1,
    modelId: 1,
    activated: true,
    channels: [1, 2, 3, 4],
  ),
  UsedLight(
    usedLightId: 1,
    modelId: 1,
    activated: true,
    channels: [1, 2, 3, 4],
  ),
];
List<Model> models = [
  Model(
    modelId: 1,
    ref: 'Model001',
    chNumber: 3,
    chTool: [
      {
        'channels': [1, 2, 3],
        'tool_id': 1,
        'label': "pallete"
      },
      {
        'channels': [4],
        'tool_id': 2,
        'label': "slider test"
      }
    ],
  ),
  Model(
    modelId: 2,
    ref: 'Model002',
    chNumber: 3,
    chTool: [
      {
        'channels': [1, 2, 3],
        'tool_id': 2,
        'label': "slider tsy vri"
      },
    ],
  ),
];
ControllerModel test=ControllerModel();
ControlerWidget controllerWidget = ControlerWidget(
  selectedUsedLights: test.selectedUsedLights,
  models: test.models,
);

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
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Exemple pour charger des données depuis la DBHelper
    final dbHelper = DBHelper();
    final fetchedModels = await dbHelper.getAllModels();

    List<UsedLight> usedLights = selectedUsedLights;

    final List<UsedLight> fetchedSelectedLights =
        selectedUsedLights; // À remplir en fonction de votre logique.

    setState(() {
      models = fetchedModels;
      selectedUsedLights = fetchedSelectedLights;
    });
  }

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
              Expanded(
                child: Consumer<ControllerModel>(
                    builder: (context, controller, child) {
                  if (controller.selectedUsedLights.isEmpty) {
                    return Center(child: Text('No lights available'));
                  }
                  return ListView.builder(
                    itemCount: controller.selectedUsedLights.length,
                    itemBuilder: (context, index) {
                      final light = controller.selectedUsedLights[index];
                      return Text(light.channels.toString());
                    },
                  );
                }),
              ),
              Expanded(child: controllerWidget),
              SizedBox(
                width: 120, // Fixe une hauteur pour le contenu
                child: UsedLightListScreen(),
              ),
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
  final GlobalKey<_ControlerWidgetState> controllerKey =
      GlobalKey<_ControlerWidgetState>();

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

      // cw.updateData(
      //     newSelectedUsedLights: [UsedLight(modelId: 1)],
      //     newModels: [Model(modelId: 1, ref: 'NewRef', chNumber: 1, chTool: [])],
      //   );
      context
          .read<ControllerModel>()
          .updateData(getSelectedUsedLights(), models);
      print(
          selectedUsedLightIds); //****************************************************************************************************ACTION ENVOYE DES USEDLIGHT VERS CONTROLLERWIDGET */
      print(getSelectedUsedLights()); // Liste des objets UsedLight sélectionnés
    } else {
      // Optionnel : Afficher une alerte si la sélection est invalide
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Vous ne pouvez sélectionner que des éléments avec le même modèle.')),
      );
    }
  }

  List<UsedLight> getSelectedUsedLights() {
    return usedLights
        .where((light) => selectedUsedLightIds.contains(light.usedLightId))
        .toList();
  }

  void _printSelectedUsedLights() {
    final selectedLights = getSelectedUsedLights();
    for (var light in selectedLights) {
      print(
          'UsedLight: ID=${light.usedLightId}, ModelID=${light.modelId}, Channels=${light.channels}');
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

class ControlerWidget extends StatefulWidget {
  // Les attributs ne sont plus marqués final pour permettre leur mise à jour.
  List<UsedLight> selectedUsedLights;
  List<Model> models;

  ControlerWidget({
    required this.selectedUsedLights,
    required this.models,
    Key? key,
  }) : super(key: key);

  @override
  _ControlerWidgetState createState() => _ControlerWidgetState();
}

class _ControlerWidgetState extends State<ControlerWidget> {
  late List<Tools> tools = []; // Liste des tools générés

  @override
  void initState() {
    super.initState();
    _generateTools();
  }

  /// Génère les outils en fonction de selectedUsedLights et models
  void _generateTools() {
    tools.clear(); // Réinitialise la liste des outils
    for (var light in widget.selectedUsedLights) {
      final model = widget.models.firstWhere(
        (model) => model.modelId == light.modelId,
        orElse: () => Model(modelId: 0, ref: '', chNumber: 0, chTool: []),
      );

      for (var toolData in model.chTool) {
        List<int> channels = toolData["channels"];
        int toolId = toolData["tool_id"];

        tools.add(Tools(
          toolsId: toolId,
          name: toolId == 1 ? 'Color Picker' : 'Slider',
          chUsed: channels.length,
          label: toolData["label"],
        ));
      }
    }

    setState(() {}); // Met à jour l'interface utilisateur
  }

  /// Méthode publique pour mettre à jour les attributs depuis d'autres classes
  void updateData({
    List<UsedLight>? newSelectedUsedLights,
    List<Model>? newModels,
  }) {
    if (newSelectedUsedLights != null) {
      widget.selectedUsedLights = newSelectedUsedLights;
    }
    if (newModels != null) {
      widget.models = newModels;
    }

    _generateTools(); // Regénère les outils en fonction des nouvelles données
  }

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return Center(
        child: Text('Aucun outil disponible'),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Défilement horizontal
        child: Row(
          children: tools.map((tool) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tool.toolsId == 1) _buildColorPicker(),
                  if (tool.toolsId == 2) _buildVerticalSlider(),
                  Text(tool.label),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    Color selectedColor = Colors.red;

    return CircleColorPicker(
      size: const Size(200, 200),
      onChanged: (color) {
        setState(() {
          selectedColor = color;
        });
      },
    );
  }

  Widget _buildVerticalSlider() {
    double value = 50;

    return RotatedBox(
      quarterTurns: 3, // Oriente le slider verticalement
      child: Slider(
        value: value,
        min: 0,
        max: 100,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
      ),
    );
  }
}
