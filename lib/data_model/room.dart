import 'package:isar/isar.dart';

part 'room.g.dart';

@collection
class Room {
  // Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  Id? id; // you can also use id = null to auto increment

  @Index(type: IndexType.value)
  String? name;

  String? data;

  // List<Recipient>? recipients;

  // @enumerated
  // Status status = Status.pending;
}

extension RoomHelper on Room{
  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }
}

// @embedded
// class Recipient {
//   String? name;
//
//   String? address;
// }
//
// enum Status {
//   draft,
//   pending,
//   sent,
// }