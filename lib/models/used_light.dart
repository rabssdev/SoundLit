class UsedLight {
  final int? usedLightId;
  final int modelId;
  final bool activated;

  UsedLight({
    this.usedLightId,
    required this.modelId,
    required this.activated,
  });

  // Ajout de copyWith
  UsedLight copyWith({
    int? usedLightId,
    int? modelId,
    bool? activated,
  }) {
    return UsedLight(
      usedLightId: usedLightId ?? this.usedLightId,
      modelId: modelId ?? this.modelId,
      activated: activated ?? this.activated,
    );
  }

  // Ajoute aussi des méthodes pour la sérialisation si nécessaire
  factory UsedLight.fromMap(Map<String, dynamic> map) {
    return UsedLight(
      usedLightId: map['used_light_id'] as int?,
      modelId: map['model_id'] as int,
      activated: (map['activated'] as int) == 1, // 1 = true, 0 = false
    );
  }

  // Conversion vers une Map
  Map<String, dynamic> toMap() {
    return {
      'used_light_id': usedLightId, // Peut être null
      'model_id': modelId,
      'activated': activated ? 1 : 0, // Convertir booléen en entier
    };
  }

}

