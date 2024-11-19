import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  ControlPageState createState() => ControlPageState();
}

class ControlPageState extends State<ControlPage> {
  final int _visibleCount = 5; // Nombre de sliders visibles
  int _startIndex = 0; // Index de départ pour les sliders affichés

  // Liste des valeurs des sliders (10 sliders par exemple)
  List<double> _sliderValues = List.generate(10, (index) => 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Sliders')),
      body: Row(
        children: [
          // Conteneur des sliders à gauche
          Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Liste des sliders visibles
                Expanded(
                  child: ListView.builder(
                    itemCount: _visibleCount,
                    itemBuilder: (context, index) {
                      int sliderIndex = _startIndex + index;
                      if (sliderIndex >= _sliderValues.length) return Container();
                      return CustomSlider(
                        label: 'CH${sliderIndex + 1}',
                        value: _sliderValues[sliderIndex],
                        onChanged: (value) {
                          setState(() {
                            _sliderValues[sliderIndex] = value;
                            print('Valeur du slider CH${sliderIndex + 1} : $value');
                          });
                        },
                      );
                    },
                  ),
                ),
                // Boutons de navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _startIndex > 0
                          ? () {
                              setState(() {
                                _startIndex -= _visibleCount;
                                if (_startIndex < 0) _startIndex = 0;
                              });
                            }
                          : null,
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: _startIndex + _visibleCount < _sliderValues.length
                          ? () {
                              setState(() {
                                _startIndex += _visibleCount;
                                if (_startIndex >= _sliderValues.length) {
                                  _startIndex = _sliderValues.length - _visibleCount;
                                }
                              });
                            }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Espace vide à droite
          Expanded(
            child: Center(
              child: const Text('Contenu principal'),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 200, // Hauteur du slider
            width: 50,   // Largeur du slider
            child: RotatedBox(
              quarterTurns: -1, // Rotation du slider pour le rendre vertical
              child: Slider(
                value: value,
                min: 0,
                max: 255,
                divisions: 255,
                label: value.round().toString(),
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
