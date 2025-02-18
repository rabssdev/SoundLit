class Succession {
  int? id;
  String name;
  List<int> statusOrder;

  Succession({
    this.id,
    required this.name,
    required this.statusOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status_order': statusOrder.join(','),
    };
  }

  factory Succession.fromMap(Map<String, dynamic> map) {
    return Succession(
      id: map['id'],
      name: map['name'],
      statusOrder:
          (map['status_order'] as String).split(',').map(int.parse).toList(),
    );
  }
}
