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
  @override
  Widget build(BuildContext context) {
    return const Column(

      children: [
        StateWidget(),
        Expanded(
          child: Row(
            children: [
              ControlWidget(),
              UsedLightListWidget()
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

    return Expanded();
  }
}
