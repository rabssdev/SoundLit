import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/controller_model.dart';

class ChannelValuesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ControllerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valeurs des Canaux'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.channels.length, (index) {
            int channelValue = controller.channels[index];

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blueGrey,
                child: Center(
                  child: Text(
                    '$channelValue',
                    style: const TextStyle(color: Colors.white),
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
