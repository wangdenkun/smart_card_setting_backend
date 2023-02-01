import 'dart:async' show Future;
import 'dart:convert';

// import 'package:isar/isar.dart';
import 'package:hive/hive.dart';

// import 'common/common.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:smart_card_setting_backend/data_model/room.dart';

const jsonHeader = {
  'content-type': 'application/json',
};

Response responseOkWithJson(Map<String, dynamic>? body) {
  return Response.ok(jsonEncode(body ?? {}), headers: jsonHeader);
}

class Service {
  Handler get handler {
    final router = Router();
    router.get('/say-hi/<name>', (Request request, String name) {
      return Response.ok('hi $name');
    });
    router.get('/user/<userId|[0-9]+>', (Request request, String userId) {
      return Response.ok('User has the user-number: $userId');
    });
    router.get('/wave', (Request request) async {
      await Future<void>.delayed(Duration(milliseconds: 100));
      return Response.ok('_o/');
    });
    router.mount('/api/', Api().router);
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found');
    });
    return router;
  }
}

class Api {
  Future<Response> _messages(Request request) async {
    return Response.ok('[]');
  }

  // By exposing a [Router] for an object, it can be mounted in other routers.
  Router get router {
    final router = Router();

    // A handler can have more that one route.
    router.get('/messages', _messages);
    router.get('/messages/', _messages);

    /// 查找某个房间的数据
    router.get('/room/<id>', (Request request) async {
      var id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: 'id!!!');
      }
      try {
        var room = roomBox.getAt(int.parse(id));
        return responseOkWithJson(room?.toMap());
      } catch (e) {
        return responseOkWithJson(null);
      }
    });

    /// 添加某个房间的数据
    router.put('/room', (Request request) async {
      var data = await request.multiPart;
      var name = data['name'] ?? '';
      var roomData = data['data'] ?? '{}';
      Room roomToAdd = Room()
        ..name = name
        ..data = roomData;
      await roomBox.add(roomToAdd);
      return responseOkWithJson(roomToAdd.toMap());
    });

    /// 修改某个房间的数据
    router.post('/room/<id>', (Request request) async {
      int? id;
      if (request.params['id'] != null) {
        id = int.parse(request.params['id']!);
      }
      var data = await request.multiPart;
      var name = data['name'] ?? '';
      var roomData = data['data'] ?? '{}';
      Room roomToAdd = Room()
        ..name = name
        ..data = roomData;
      if (id != null && roomBox.containsKey(id)) {
        var savedRoom = roomBox.getAt(id);
        savedRoom?.name = roomToAdd.name;
        savedRoom?.data = roomToAdd.data;
        await savedRoom?.save();
      } else {
        roomBox.add(roomToAdd);
      }
      var savedRoom = roomBox.getAt(id!);
      return responseOkWithJson(savedRoom?.toMap());
    });

    /// 查看房间列表
    router.get('/rooms', (Request request) async {
      var res = roomBox.values.toList();
      var resResponseList = res
          .map((e) => e.toMap())
          .toList();
      return responseOkWithJson({
        'data': resResponseList,
      });
    });

    // This nested catch-all, will only catch /api/.* when mounted above.
    // Notice that ordering if annotated handlers and mounts is significant.
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));

    return router;
  }
}

// late Isar isar;
late Box<Room> roomBox;
// Run shelf server and host a [Service] instance on port 8080.
void main() async {
  // CollectionSchema roomSchema = CollectionSchema();
  // isar = await Isar.open([RoomSchema]);
  Hive.init('./');
  Hive.registerAdapter(RoomAdapter());
  roomBox = await Hive.openBox<Room>('room');
  final service = Service();
  final server = await shelf_io.serve(service.handler, 'localhost', 2222);
  print('Server running on localhost:${server.port}');
}

extension RequestHelper on Request {
  Future<Map<String, String>> get multiPart => _getMultiPart();

  Future<Map<String, String>> _getMultiPart() async {
    if (isMultipart) {
      final parameters = <String, String>{
        await for (final formData in multipartFormData) formData.name: await formData.part.readString(),
      };
      return parameters;
    } else {
      return {};
    }
  }
}
