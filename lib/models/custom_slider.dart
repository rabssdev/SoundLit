import 'dart:async';
import 'package:flutter/material.dart';

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
