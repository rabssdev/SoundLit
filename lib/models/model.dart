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
      'ch_tool': chTool.map((e) => '${e['channels']}:${e['tool_id']}').join(','), // Sérialisation
    };
  }

  // Conversion d'un map SQLite en objet `Model`
  factory Model.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> chToolParsed = [];
    if (map['ch_tool'] != null) {
      chToolParsed = (map['ch_tool'] as String)
          .split(',')
          .map((e) {
            final parts = e.split(':');
            return {
              'channels': parts[0].split(';').map(int.parse).toList(),
              'tool_id': int.parse(parts[1]),
            };
          })
          .toList();
    }
    return Model(
      modelId: map['model_id'],
      ref: map['ref'],
      chNumber: map['ch_number'],
      chTool: chToolParsed,
    );
  }
}
