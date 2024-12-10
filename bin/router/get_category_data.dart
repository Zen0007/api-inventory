import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATABORROW";

Future<void> getDataCollection({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    await dataBase.open();

    final String nameCollection = payload['collection'];

    final data = await collection.find(where.exists(nameCollection)).toList();
    if (data.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "data collection Is empty ",
        },
      ));
    }

    var results = [];
    for (var element in data) {
      element[nameCollection].forEach((key, value) {
        if (value['status'] == 'available') {
          results.add(value);
        }
      });
    }

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": results,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
