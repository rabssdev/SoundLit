class StateModel {
  final int? id;
  final String name;
  final List<int> channelList;

  StateModel({
    this.id,
    required this.name,
    required this.channelList,
  });

  // Convert a StateModel object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'channel_list': channelList.join(','), // Convert list to a string
    };
  }

  // Convert a Map into a StateModel object
  factory StateModel.fromMap(Map<String, dynamic> map) {
    return StateModel(
      id: map['id'],
      name: map['name'],
      channelList: map['channel_list']
          .split(',')
          .map((e) => int.parse(e))
          .toList(),
    );
  }
}
