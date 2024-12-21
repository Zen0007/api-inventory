import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATABORROW";

Future<void> getDataBorrow({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
}) async {
  try {
    await dataBase.open();
    final getData = await collection.find().toList();
    if (getData.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "data borrowing Is empty ",
        },
      ));
      return;
    }

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": getData,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
