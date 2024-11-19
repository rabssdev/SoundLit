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
  final List<double> _sliderValues =
      List.generate(22, (index) => 128.0); // Valeurs initiales des sliders
  int _currentPage = 0; // Page actuelle

  @override
  Widget build(BuildContext context) {
    // Calcul du nombre total de pages nécessaires
    int totalPages = (totalSliders / slidersPerPage).ceil();

    // Déterminer la plage des sliders à afficher
    int start = _currentPage * slidersPerPage;
    int end =
        (_currentPage * slidersPerPage + slidersPerPage).clamp(0, totalSliders);

    return Column(//*********************************************COLONNE COLONNE COLONNE */
      
      children: [
        

        //AJOUT D'UN ELEMENT EN HAUT
      
        Expanded(
          child: Row( //**********************************************ROW ROW ROW */
            children: [
              
              //AJOUT D'UN ELEMENT A DROITE

              Expanded(
                child: Container(
                  color: Colors.white, // Définir l'arrière-plan blanc
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bouton "Preview" à gauche
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                              50, double.infinity), // Bouton plein en hauteur
                          padding: EdgeInsets.zero, // Pas de padding
                        ),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null, // Désactiver si déjà sur la première page
                        child: const RotatedBox(
                          quarterTurns: 3,
                          child: Text('Preview', textAlign: TextAlign.center),
                        ),
                      ),
                      // Sliders au centre
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double sliderWidth = constraints
                                .maxWidth; // Largeur disponible pour les sliders
                            return Center(
                              child: Wrap(
                                spacing:
                                    0, // Pas d'espace horizontal entre les sliders
                                runSpacing:
                                    8, // Espacement vertical entre les lignes
                                children: List.generate(end - start, (index) {
                                  int sliderIndex = start + index;
                                  return SizedBox(
                                    width: sliderWidth /
                                        slidersPerPage, // Partage équitable de l'espace
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomSlider(
                                          label: 'Slider ${sliderIndex + 1}',
                                          value: _sliderValues[sliderIndex],
                                          onChanged: (newValue) {
                                            setState(() {
                                              _sliderValues[sliderIndex] =
                                                  newValue;
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                            height:
                                                2), // Espacement entre le slider et le label
                                        Text(
                                          'CH${sliderIndex + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                      // Bouton "Next" à droite
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                              50, double.infinity), // Bouton plein en hauteur
                          padding: EdgeInsets.zero, // Pas de padding
                        ),
                        onPressed: _currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null, // Désactiver si déjà sur la dernière page
                        child: const RotatedBox(
                          quarterTurns: 1,
                          child: Text('Next', textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
            ],
          ),
        ),


        //AJOUT D'UN ELEMENT EN BAS
      
      ],
    );
  }
}
