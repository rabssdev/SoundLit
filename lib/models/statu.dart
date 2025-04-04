class Statu {
  int? statuId; // Clé primaire
  List<int> channels; // Liste de canaux
  bool activated; // Statut activé
  int delayAfter; // Délai après

  Statu({
    this.statuId,
    required this.channels,
    required this.activated,
    required this.delayAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'statu_id': statuId,
      'channels': channels.join(','),
      'activated': activated ? 1 : 0,
      'delay_after': delayAfter,
    };
  }

  factory Statu.fromMap(Map<String, dynamic> map) {
    return Statu(
      statuId: map['statu_id'],
      channels: (map['channels'] as String).split(',').map(int.parse).toList(),
      activated: map['activated'] == 1,
      delayAfter: map['delay_after'],
    );
  }
}
