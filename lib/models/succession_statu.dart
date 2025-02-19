class SuccessionStatu {
  int? id;
  int successionId;
  List<int> channels;
  int delayAfter;

  SuccessionStatu({
    this.id,
    required this.successionId,
    required this.channels,
    required this.delayAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'succession_id': successionId,
      'channels': channels.join(','),
      'delay_after': delayAfter,
    };
  }

  factory SuccessionStatu.fromMap(Map<String, dynamic> map) {
    return SuccessionStatu(
      id: map['id'],
      successionId: map['succession_id'],
      channels: (map['channels'] as String).split(',').map(int.parse).toList(),
      delayAfter: map['delay_after'],
    );
  }
}
