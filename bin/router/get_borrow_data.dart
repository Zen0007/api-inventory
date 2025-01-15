import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATABORROW";

Future<void> getDataBorrow({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final getData = await collection.find().toList();

    final pipeline = <Map<String, Object>>[];
    final change = collection.watch(pipeline);

    await for (var status in change) {
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
        return;
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

Future<void> getDataBorrowOnce({
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
