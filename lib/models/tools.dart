class Tools {
  final int? toolsId; // nullable pour gérer les IDs auto-incrémentés
  final String name;
  final int chUsed;

  Tools({this.toolsId, required this.name, required this.chUsed});

  // Convertir un objet Tools en map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'tools_id': toolsId,
      'name': name,
      'ch_used': chUsed,
    };
  }

  // Convertir un map (de SQLite) en objet Tools
  factory Tools.fromMap(Map<String, dynamic> map) {
    return Tools(
      toolsId: map['tools_id'],
      name: map['name'],
      chUsed: map['ch_used'],
    );
  }
}
