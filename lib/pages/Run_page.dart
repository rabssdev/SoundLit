import 'package:flutter/material.dart';

class RunPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleDragAndDropPage()
    );
  }
}


//ECHANGE DE CERCLE
class CircleDragAndDropPage extends StatefulWidget {
  @override
  _CircleDragAndDropPageState createState() => _CircleDragAndDropPageState();
}

class _CircleDragAndDropPageState extends State<CircleDragAndDropPage> {
  // Liste des numéros affichés dans les cercles
  List<int> circles = List.generate(10, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Échange de cercles"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: circles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5 cercles par ligne
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return DragTarget<int>(
              onAccept: (fromIndex) {
                // Échanger les cercles
                setState(() {
                  final temp = circles[fromIndex];
                  circles[fromIndex] = circles[index];
                  circles[index] = temp;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Draggable<int>(
                  data: index,
                  feedback: CircleWidget(
                    number: circles[index],
                    isDragging: true,
                  ),
                  childWhenDragging: CircleWidget(
                    number: circles[index],
                    isDragging: false,
                    isPlaceholder: true,
                  ),
                  child: CircleWidget(
                    number: circles[index],
                    isDragging: false,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final int number;
  final bool isDragging;
  final bool isPlaceholder;

  const CircleWidget({
    required this.number,
    required this.isDragging,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaceholder ? Colors.grey[300] : Colors.green,
        shape: BoxShape.circle,
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        isPlaceholder ? "" : "$number",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
