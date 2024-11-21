class Light {
  final int? id; // Optional for SQLite autoincrement
  final String name;
  final int number;
  final bool state;
  final List<int> channelList; // New variable as a list of integers

  Light({
    this.id,
    required this.name,
    required this.number,
    required this.state,
    required this.channelList, // Updated constructor
  });

  // Convert a Light object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'state': state ? 1 : 0, // Store boolean as 0/1 in SQLite
      'channel_list': channelList.join(','), // Convert list to a comma-separated string
    };
  }

  // Convert a Map into a Light object
  factory Light.fromMap(Map<String, dynamic> map) {
    return Light(
      id: map['id'],
      name: map['name'],
      number: map['number'],
      state: map['state'] == 1,
      channelList: map['channel_list'] != null 
          ? map['channel_list'].split(',').map((e) => int.parse(e)).toList() 
          : [], // Convert comma-separated string back to list of integers
    );
  }
}
