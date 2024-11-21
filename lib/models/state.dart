class State {
  final int? stateId; // Clé primaire
  final List<int> channels; // Liste de canaux
  final bool activated; // Statut activé
  final int delayAfter; // Délai après

  State({
    this.stateId,
    required this.channels,
    required this.activated,
    required this.delayAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'state_id': stateId,
      'channels': channels.join(','),
      'activated': activated ? 1 : 0,
      'delay_after': delayAfter,
    };
  }

  factory State.fromMap(Map<String, dynamic> map) {
    return State(
      stateId: map['state_id'],
      channels: (map['channels'] as String).split(',').map(int.parse).toList(),
      activated: map['activated'] == 1,
      delayAfter: map['delay_after'],
    );
  }
}
