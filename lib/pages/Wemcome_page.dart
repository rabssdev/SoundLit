import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/circle_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'dart:convert';
import '../models/model.dart'; // Importer la classe Model
import '../database/db_helper.dart'; // Importer la classe DBHelper
import '../pages/Control_page.dart';
import '../models/statu.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cercles avec Activation'),
        ),
        body: CircleScroller(totalCircles: 10,visibleCircles: 5,circleDiameter: 20),
      ),
    );
  }
}

//****************************COLOR PICKER */

class ColorPickerPage extends StatefulWidget {
  @override
  _ColorPickerPageState createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color selectedColor = Colors.red; // Couleur par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélecteur de couleur simple'),
        backgroundColor: selectedColor,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleColorPicker(
              size: const Size(150, 150),
              onChanged: _onColorChanged,
              textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              thumbSize: 12,
            ),
            // const SizedBox(height: 20),
            Text(
              'R: ${selectedColor.red}, G: ${selectedColor.green}, B: ${selectedColor.blue}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _onColorChanged(Color color) {
    setState(() {
      selectedColor = color;
    });
  }
}

class CircleScroller extends StatefulWidget {
  final int totalCircles;
  final int visibleCircles;
  final double circleDiameter;

  CircleScroller({
    required this.totalCircles,
    required this.visibleCircles,
    required this.circleDiameter,
  });

  @override
  _CircleScrollerState createState() => _CircleScrollerState();
}

class _CircleScrollerState extends State<CircleScroller> {
  late List<CircleItem> circles;
  int? activeIndex;

  @override
  void initState() {
    super.initState();
    // Initialisation des cercles avec des valeurs par défaut
    circles = List.generate(
      widget.totalCircles,
      (index) => CircleItem(
        couleur: Colors.white,
        stateCircle: false,
        numero: index + 1,
      ),
    );
  }

  void activateCircle(int index) {
    setState(() {
      // Désactiver l'ancien cercle actif
      if (activeIndex != null) {
        circles[activeIndex!].couleur = Colors.white;
        circles[activeIndex!].stateCircle = false;
      }
      // Activer le nouveau cercle
      circles[index].couleur = Colors.green;
      circles[index].stateCircle = true;
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double circleSpacing = 10.0;

    return Center(
      child: SizedBox(
        height: widget.circleDiameter,
        width: widget.circleDiameter * 5 +
            40, //***************************************width du widget */
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.totalCircles,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final circle = circles[index];
            return GestureDetector(
              onTap: () => activateCircle(index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: circleSpacing / 2),
                width: widget.circleDiameter,
                height: widget.circleDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circle.couleur,
                  border: Border.all(
                    color: Colors.black,
                    width: 5.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${circle.numero}',
                    style: TextStyle(
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
    );
  }
}

class ModelListPage extends StatefulWidget {
  @override
  _ModelListPageState createState() => _ModelListPageState();
}

class _ModelListPageState extends State<ModelListPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Model> _models = [];

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    final models = await _dbHelper.getAllModels();
    setState(() {
      _models = models;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Modèles'),
      ),
      body: _models.isEmpty
          ? Center(
              child: Text(
                'Aucun modèle trouvé.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _models.length,
              itemBuilder: (context, index) {
                final model = _models[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      'Modèle: ${model.ref}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${model.modelId ?? "N/A"}'),
                        Text('Nombre de canaux: ${model.chNumber}'),
                        Text(
                          'Outils: ${jsonEncode(model.chTool)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Action pour ajouter un modèle ou recharger la liste
          _fetchModels();
        },
        child: Icon(Icons.refresh),
        tooltip: 'Rafraîchir la liste',
      ),
    );
  }
}












class StatuListPage extends StatefulWidget {
  @override
  _StatuListPageState createState() => _StatuListPageState();
}

class _StatuListPageState extends State<StatuListPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Statu> _status = [];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  /// Récupère tous les statuts depuis la base de données
  Future<void> _fetchStatus() async {
    final status = await _dbHelper.getAllStatus();
    setState(() {
      _status = status;
    });
  }

  /// Met à jour les channels du statut sélectionné depuis le provider
  Future<void> _updateStatuChannels(Statu statu) async {
    final controller = Provider.of<ControllerModel>(context, listen: false);
    statu.channels = List.from(controller.channels);
    await _dbHelper.updateStatu(statu);
    _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Statuts"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchStatus, // Rafraîchir la liste des statuts
          ),
        ],
      ),
      body: _status.isEmpty
          ? Center(
              child: Text(
                "Aucun statut disponible.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _status.length,
              itemBuilder: (context, index) {
                final statu = _status[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Statut #${statu.statuId ?? '-'}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Activé : ${statu.activated ? 'Oui' : 'Non'}",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Délai après : ${statu.delayAfter} ms",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Canaux :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        // Affiche les valeurs des channels dans un conteneur défilant horizontalement
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            statu.channels.join(", "),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _updateStatuChannels(statu),
                          child: Text("Mettre à jour avec les valeurs actuelles"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}