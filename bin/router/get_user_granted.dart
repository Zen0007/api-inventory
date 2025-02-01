import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAGRANTED";

Future<void> getDataGranted({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final data = await collection.find().toList();
    if (data.isEmpty) {
      return; // prevent for exsecute code below
    }

    final List<Map<String, Object>> pipeline = [];
    final watch = collection.watch(pipeline);

    await for (var status in watch) {
      if (status.isUpdate || status.isInsert || status.isDelete) {
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": data,
            },
          ),
        );
      }
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> getDataGrantedOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final getData = await collection.find().toList();
    socket.sink.add(
      json.encode(
        {
          endpoint: valueEdnpoint,
          "message": getData,
        },
      ),
    );
  } catch (e, s) {
    print(e);
    print(s);
  }
}
