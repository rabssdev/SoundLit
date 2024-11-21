class UsedLight {
  final int? usedLightId; // Clé primaire
  final int modelId; // Clé étrangère vers Model
  final bool activated; // Statut activé

  UsedLight({
    this.usedLightId,
    required this.modelId,
    required this.activated,
  });

  Map<String, dynamic> toMap() {
    return {
      'used_light_id': usedLightId,
      'model_id': modelId,
      'activated': activated ? 1 : 0,
    };
  }

  factory UsedLight.fromMap(Map<String, dynamic> map) {
    return UsedLight(
      usedLightId: map['used_light_id'],
      modelId: map['model_id'],
      activated: map['activated'] == 1,
    );
  }
}
