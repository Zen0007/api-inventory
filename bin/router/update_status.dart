import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "UPDATESTATUSITEM";

Future<void> updateStatusItem({
  required WebSocketChannel socket,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    final nameCategory = payload['category'];
    final indexItem = payload['index'];

    final findIndex = await collection.findOne(where.exists(nameCategory));
    if (findIndex == null) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "failed to update status",
          },
        ),
      );
      return;
    }
    if (findIndex[nameCategory][indexItem] == null) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "failed to update status",
          },
        ),
      );
      return;
    }

    final updateStatusItem = await collection.updateOne(
      where.id(findIndex["_id"]),
      modify.set("$nameCategory.$indexItem.status", "borrow"),
    );

    if (updateStatusItem.isSuccess) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          "message": "success",
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
  }
}
