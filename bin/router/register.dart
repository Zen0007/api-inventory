import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> addNewAdmin({
  dynamic payload,
  required WebSocketChannel socket,
  required DbCollection authAdmin,
  required Db dataBase,
}) async {
  try {
    await dataBase.open();
    final nameNewAdmin = payload['name'];
    final passowrd = payload['password'];
    if (nameNewAdmin == null || passowrd == null) {
      socket.sink.add(json.encode({
        "endpoint": "REGISTER",
        "message": "user name or password must fill "
      }));
    }

    final findUser = await authAdmin.findOne(where.eq("name", nameNewAdmin));
    if (findUser != null) {
      socket.sink.add(json.encode({
        "endpoint": "REGISTER",
        "message": "name user alredy exists",
      }));
    }

    await authAdmin.insert({
      nameNewAdmin: {
        "name": nameNewAdmin,
        "password": passowrd,
      }
    });

    socket.sink.add(json
        .encode({"endpoint": "REGISTER", "message": "succes add new admin"}));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
