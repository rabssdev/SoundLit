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
  List<UsedLight> selectedUsedLights = [];
  List<Model> models = [];
  List<int> channels =
      List.generate(512, (_) => 0); // Initialise 512 channels à 0

  /// Met à jour les données `selectedUsedLights` et `models`
  void updateData(List<UsedLight>? newUsedLights, List<Model>? newModels) {
    if (newUsedLights != null) {
      selectedUsedLights = newUsedLights;
    }
    if (newModels != null) {
      models = newModels;
    }
    notifyListeners();
  }

  /// Met à jour une valeur spécifique dans le tableau `channels`
  void updateChannelValue(int index, int value) {
    if (index >= 0 && index < channels.length) {
      channels[index] = value;
      notifyListeners();
    } else {
      throw RangeError('Index $index is out of bounds for channels');
    }
  }

  /// Réinitialise tous les channels à 0
  void resetChannels() {
    channels.fillRange(0, channels.length, 0);
    notifyListeners();
  }
}

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
// À remplir en fonction de votre logique.

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120, // Fixe une hauteur pour le contenu
          // child: HorizontalStatuManager(),
          child: ChannelValuesWidget(),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: ControlerWidget()),
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
  List<Model> models = [];
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
    this.models = await dbHelper.getAllModels();

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
  ControlerWidget({Key? key}) : super(key: key);

  @override
  _ControlerWidgetState createState() => _ControlerWidgetState();
}

class _ControlerWidgetState extends State<ControlerWidget> {
  late List<Tools> tools = []; // Liste des tools générés
  late List<List<List<int>>> tool_channels =
      []; // Liste des channels groupés par outils

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Générer les tools après le premier rendu
      final controller = Provider.of<ControllerModel>(context, listen: false);
      _generateTools(controller);
    });
  }

  /// Génère les outils en fonction de `selectedUsedLights` et des modèles
  void _generateTools(ControllerModel controller) {
    tools.clear(); // Réinitialise la liste des outils
    tool_channels.clear();
    for (var light in controller.selectedUsedLights) {
      final model = controller.models.firstWhere(
        (model) => model.modelId == light.modelId,
        orElse: () => Model(modelId: 0, ref: '', chNumber: 0, chTool: []),
      );

      for (var i = 0; i < model.chTool.length; i++) {
        final toolData = model.chTool[i];
        List<int> channels = toolData["channels"];
        int toolId = toolData["tool_id"];

        // Filtrer les canaux pour s'assurer qu'ils existent
        final validChannels =
            channels.where((ch) => ch < (light.channels.length) + 1).toList();
        print(validChannels.toString());
        // Si des canaux valides existent, ajouter à la liste
        if (validChannels.isNotEmpty) {
          if (tools.length > i) {
            tool_channels[i]
                .add(validChannels.map((ch) => light.channels[ch-1]).toList());
          // }
          } else {
            tool_channels
                .add([validChannels.map((ch) => light.channels[ch-1]).toList()]);
            tools.add(Tools(
              toolsId: toolId,
              name: toolId == 1 ? 'Color Picker' : 'Slider',
              chUsed: validChannels.length,
              label: toolData["label"],
            ));
          }
        }
      }
    }

    setState(() {}); // Met à jour l'interface utilisateur
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements dans ControllerModel
    final controller = Provider.of<ControllerModel>(context);

    // Regénérer les tools à chaque changement de données
    _generateTools(controller);

    if (tools.isEmpty) {
      return Center(
        child: Text('Aucun outil disponible'),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Défilement horizontal
        child: Row(
          children: tools.asMap().entries.map((entry) {
            final index = entry.key;
            final tool = tools[index];
            final channelsGroup = tool_channels[index];

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tool.toolsId == 2) _buildColorPicker(channelsGroup),
                  if (tool.toolsId == 1)
                    _buildVerticalSlider(controller, channelsGroup),
                  Text("Channels: ${channelsGroup.expand((e) => e).toList()}"),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Génère un color picker pour contrôler plusieurs groupes de canaux RGB
  Widget _buildColorPicker(List<List<int>> channelGroups) {
    Color selectedColor = Colors.red;

    return CircleColorPicker(
      size: const Size(200, 200),
      onChanged: (color) {
        setState(() {
          selectedColor = color;

          // Extraire les composantes RVB du color
          int red = color.red; // Valeur de R (0 à 255)
          int green = color.green; // Valeur de G (0 à 255)
          int blue = color.blue; // Valeur de B (0 à 255)

          // Mettre à jour les valeurs RVB pour tous les groupes de canaux
          for (var channels in channelGroups) {
            if (channels.length >= 3) {
              context
                  .read<ControllerModel>()
                  .updateChannelValue(channels[0]-1, red);
              context
                  .read<ControllerModel>()
                  .updateChannelValue(channels[1]-1, green);
              context
                  .read<ControllerModel>()
                  .updateChannelValue(channels[2]-1, blue);
            }
          }
        });
      },
    );
  }

  /// Génère un slider vertical pour contrôler un groupe de canaux
  Widget _buildVerticalSlider(
      ControllerModel controller, List<List<int>> channelGroups) {
    // Calculer la valeur moyenne initiale des canaux
    double initialValue = channelGroups
            .expand((channels) => channels.map((ch) => controller.channels[ch]))
            .reduce((a, b) => a + b)
            .toDouble() /
        (channelGroups.expand((e) => e).length); // Diviser par le total réel

    return RotatedBox(
      quarterTurns: 3, // Oriente le slider verticalement
      child: Slider(
        value: initialValue.clamp(0, 255), // S'assurer que la valeur est valide
        min: 0,
        max: 255, // Plage de 0 à 255
        onChanged: (newValue) {
          setState(() {
            // Mettre à jour tous les canaux pour chaque groupe
            for (var channels in channelGroups) {
              for (var ch in channels) {
                context
                    .read<ControllerModel>()
                    .updateChannelValue(ch-1, newValue.toInt());
              }
            }
          });
        },
      ),
    );
  }
}

class ChannelValuesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Écouter les changements dans ControllerModel
    final controller = Provider.of<ControllerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Valeurs des Canaux'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Défilement horizontal
        child: Row(
          children: List.generate(controller.channels.length, (index) {
            int channelValue = controller.channels[index];

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 50, // Largeur d'un élément
                height: 50, // Hauteur d'un élément
                color: Colors.blueGrey,
                child: Center(
                  child: Text(
                    '$channelValue', // Affiche la valeur du canal
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
