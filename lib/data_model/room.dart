import '../common/common.dart';

// isar
//
part 'room.g.dart';
//
// @collection
// class Room {
//   // Id id = Isar.autoIncrement; // you can also use id = null to auto increment
//   Id? id; // you can also use id = null to auto increment
//
//   @Index(type: IndexType.value)
//   String? name;
//
//   String? data;
//
//   // List<Recipient>? recipients;
//
//   // @enumerated
//   // Status status = Status.pending;
// }
//
extension RoomHelper on Room{
  Map<String,dynamic> toMap(){
    return {
      'id': key,
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


// hive

@HiveType(typeId: 0)
class Room extends HiveObject {

  // @HiveField(0)
  // late int id;

  @HiveField(1,defaultValue: '')
  late String name;

  @HiveField(2,defaultValue: '{}')
  late String data;
}