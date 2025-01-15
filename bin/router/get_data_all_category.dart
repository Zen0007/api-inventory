import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAALLCATEGORY";

Future<void> getDataAllCategory({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final data = await collection.find().toList();
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
            "message": data,
          },
        ));
      } else if (data.isEmpty) {
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

// PUT IN ONPRESS
Future<void> getDataAllCategoryOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final data = await collection.find().toList();
    if (data.isEmpty) {
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
        "message": data,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
