class Light {
  final int? id; // Optional for SQLite autoincrement
  final String name;
  final int number;
  final bool state;
  final int channelNumber;

  Light({
    this.id,
    required this.name,
    required this.number,
    required this.state,
    required this.channelNumber,
  });

  // Convert a Light object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'state': state ? 1 : 0, // Store boolean as 0/1 in SQLite
      'channel_number': channelNumber,
    };
  }

  // Convert a Map into a Light object
  factory Light.fromMap(Map<String, dynamic> map) {
    return Light(
      id: map['id'],
      name: map['name'],
      number: map['number'],
      state: map['state'] == 1,
      channelNumber: map['channel_number'],
    );
  }
}
