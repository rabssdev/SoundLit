import 'succession_statu.dart';
import 'statu.dart';
import '../database/db_helper.dart';

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

  Future<void> duplicateStatusToSuccession(
      List<Statu> statusList, int successionId) async {
    final dbHelper = DBHelper();
    for (var statu in statusList) {
      final successionStatu = SuccessionStatu(
        successionId: successionId,
        channels: statu.channels,
        delayAfter: statu.delayAfter,
      );
      final insertedId = await dbHelper.insertSuccessionStatu(successionStatu);
      print(
          "Inserted SuccessionStatu ID: $insertedId"); // Debugging information
    }
    // Verify the inserted SuccessionStatu entries
    final insertedStatus = await dbHelper.getSuccessionStatus(successionId);
    print(
        "Inserted SuccessionStatu entries: $insertedStatus"); // Debugging information
  }
}
