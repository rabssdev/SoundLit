import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/circle_item.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cercles avec Activation'),
        ),
        body: CircleScroller(
          totalCircles: 21,
          visibleCircles: 5,
          circleDiameter: 80.0,
        ),
      ),
    );
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
        width: widget.circleDiameter * 5 +40,//***************************************width du widget */
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