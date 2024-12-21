import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "UPDATESTATUSITEM";

Future<void> updateStatusItem({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    await dataBase.open();
    final nameCategory = payload['category'];
    final indexItem = payload['index'];

    final findIndex = await collection.findOne(where.exists(nameCategory));

    final updateStatusItem = await collection.updateOne(
      where.id(findIndex!["_id"]),
      modify.set("$nameCategory.$indexItem.status", "borrow"),
    );

    if (updateStatusItem.isSuccess) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          "message": "success to update item",
        },
      ));
      return;
    } else {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "failed update",
        },
      ));
    }
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
