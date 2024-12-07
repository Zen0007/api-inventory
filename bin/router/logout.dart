import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> logout(
    {required dynamic payload,
    required WebSocketChannel socket,
    required DbCollection colection,
    required Db dataBase}) async {
  try {
    await dataBase.open();
    final data = payload['token'];
    await colection.insertOne({"token": data});

    socket.sink
        .add(json.encode({"endpoint": "LOGOUT", "message": "lougut success"}));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
