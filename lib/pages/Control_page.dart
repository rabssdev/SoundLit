import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/custom_slider.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  ControlPageState createState() => ControlPageState();
}

class ControlPageState extends State<ControlPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Gestion des Sliders')),
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
  final int totalSliders = 22; // Nombre total de sliders
  final int slidersPerPage = 5; // Nombre de sliders par page
  final List<double> _sliderValues = List.generate(22, (index) => 128.0); // Valeurs initiales des sliders
  int _currentPage = 0; // Page actuelle

  @override
  Widget build(BuildContext context) {
    // Calcul du nombre total de pages nécessaires
    int totalPages = (totalSliders / slidersPerPage).ceil();

    // Déterminer la plage des sliders à afficher
    int start = _currentPage * slidersPerPage;
    int end = (_currentPage * slidersPerPage + slidersPerPage).clamp(0, totalSliders);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              spacing: 1, // Espacement horizontal minimum entre les sliders
              runSpacing: 20, // Espacement vertical entre les lignes si nécessaire
              children: List.generate(end - start, (index) {
                int sliderIndex = start + index;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSlider(
                      label: 'Slider ${sliderIndex + 1}',
                      value: _sliderValues[sliderIndex],
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValues[sliderIndex] = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 8), // Espacement entre le slider et le label
                    Text(
                      'CH${sliderIndex + 1}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white70),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null, // Désactiver si déjà sur la première page
              child: const Text('Preview'),
            ),
            Text(
              'Page ${_currentPage + 1} / $totalPages',
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null, // Désactiver si déjà sur la dernière page
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}