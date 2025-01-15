import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAPENDING";

Future<void> getDataPending({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final getData = await collection.find().toList();
    final List<Map<String, Object>> pipeline = [];
    final watch = collection.watch(pipeline);

    await for (var status in watch) {
      if (status.isUpdate ||
          status.isInsert ||
          status.isDelete ||
          status.isReplace ||
          status.isRename) {
        socket.sink.add(json.encode(
          {
            endpoint: valueEdnpoint,
            "message": getData,
          },
        ));
      } else if (getData.isEmpty) {
        socket.sink.add(json.encode(
          {
            endpoint: valueEdnpoint,
            "message": [],
          },
        ));
        return;
      }
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> getDataPendingOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final getData = await collection.find().toList();
    if (getData.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          "message": [],
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
  }
}
