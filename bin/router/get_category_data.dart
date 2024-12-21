import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATACATEGORY";

Future<void> getDataCategory({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
}) async {
  try {
    await dataBase.open();

    final data = await collection.find().toList();
    if (data.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "data collection Is empty ",
        },
      ));
      return;
    }

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": data,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
