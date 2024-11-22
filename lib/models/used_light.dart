class UsedLight {
  final int? usedLightId;
  final int modelId;
  final bool activated;
  final List<int> channels; // Nouveau champ

  UsedLight({
    this.usedLightId,
    required this.modelId,
    required this.activated,
    required this.channels,
  });

  // Ajout de copyWith pour 'channels'
  UsedLight copyWith({
    int? usedLightId,
    int? modelId,
    bool? activated,
    List<int>? channels,
  }) {
    return UsedLight(
      usedLightId: usedLightId ?? this.usedLightId,
      modelId: modelId ?? this.modelId,
      activated: activated ?? this.activated,
      channels: channels ?? this.channels,
    );
  }

  // Méthode de sérialisation : Map vers objet
  factory UsedLight.fromMap(Map<String, dynamic> map) {
    return UsedLight(
      usedLightId: map['used_light_id'] as int?,
      modelId: map['model_id'] as int,
      activated: (map['activated'] as int) == 1,
      channels: (map['channels'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList(), // Convertit la chaîne en liste d'entiers
    );
  }

  // Méthode de sérialisation : objet vers Map
  Map<String, dynamic> toMap() {
    return {
      'used_light_id': usedLightId,
      'model_id': modelId,
      'activated': activated ? 1 : 0,
      'channels': channels.join(','), // Convertit la liste d'entiers en chaîne
    };
  }
}
