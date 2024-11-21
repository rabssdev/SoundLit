import 'dart:convert';

class Model {
  final int? modelId; // Clé primaire
  final String ref; // Référence du modèle
  final int chNumber; // Nombre de canaux
  final List<Map<String, dynamic>> chTool; // Liste de couples [(array of channel), tool_id]

  Model({
    this.modelId,
    required this.ref,
    required this.chNumber,
    required this.chTool,
  });

  // Conversion d'un objet `Model` en map pour SQLite
  Map<String, dynamic> toMap() {
  return {
    'model_id': modelId,
    'ref': ref,
    'ch_number': chNumber,
    'ch_tool': jsonEncode(chTool), // Conversion en JSON
  };
}

  // Conversion d'un map SQLite en objet `Model`
  factory Model.fromMap(Map<String, dynamic> map) {
  List<Map<String, dynamic>> chToolParsed = [];
  if (map['ch_tool'] != null) {
    chToolParsed = List<Map<String, dynamic>>.from(
      jsonDecode(map['ch_tool']).map((e) => {
            'channels': List<int>.from(e['channels']),
            'tool_id': e['tool_id'],
          }),
    );
  }

  return Model(
    modelId: map['model_id'],
    ref: map['ref'],
    chNumber: map['ch_number'],
    chTool: chToolParsed,
  );
}

}
