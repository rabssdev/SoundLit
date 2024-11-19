import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final int _visibleCount = 5; // Nombre de sliders visibles par page
  int _startIndex = 0; // Index de départ pour les sliders affichés

  // Liste des valeurs des sliders (10 sliders dans cet exemple)
  List<double> _sliderValues = List.generate(10, (index) => 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Gestion des Sliders')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacement des boutons
          children: [
            // Bouton "Preview" à gauche
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: _startIndex > 0
                  ? () {
                      setState(() {
                        _startIndex = (_startIndex - _visibleCount).clamp(0, _sliderValues.length - _visibleCount);
                      });
                    }
                  : null,
            ),
            // Conteneur des sliders avec un défilement horizontal
            Expanded(
              child: Container(
                height: 250, // Hauteur ajustée des sliders
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Défilement horizontal
                  itemCount: _visibleCount, // Afficher les sliders en groupes de 5
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
            ),
            // Bouton "Next" à droite
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: _startIndex + _visibleCount < _sliderValues.length
                  ? () {
                      setState(() {
                        _startIndex = (_startIndex + _visibleCount).clamp(0, _sliderValues.length - _visibleCount);
                      });
                    }
                  : null,
            ),
          ],
        ),
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
            height: 180, // Hauteur du slider
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
