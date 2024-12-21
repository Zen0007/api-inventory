import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "LOGOUT";

Future<void> logout(
    {required dynamic payload,
    required WebSocketChannel socket,
    required DbCollection colection,
    required Db dataBase}) async {
  try {
    await dataBase.open();
    final data = payload['token'];
    final logout = await colection.insertOne({"token": data});

    if (logout.success) {
      socket.sink.add(
          json.encode({endpoint: valueEdnpoint, "message": "lougut success"}));
      return;
    } else {
      socket.sink.add(
          json.encode({endpoint: valueEdnpoint, warning: "lougut failed"}));
    }
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
