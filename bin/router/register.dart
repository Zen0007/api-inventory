import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> addNewAdmin(
    dynamic payload, WebSocketChannel socket, DbCollection authAdmin) async {
  try {
    final nameNewAdmin = payload['name'];
    final passowrd = payload['password'];
    if (nameNewAdmin == null || passowrd == null) {
      socket.sink
          .add(json.encode({"message": "user name or password must fill "}));
    }

    await authAdmin.insert({
      nameNewAdmin: {
        "name": nameNewAdmin,
        "password": passowrd,
      }
    });

    socket.sink.add(json.encode({"message": "succes add new admin"}));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
