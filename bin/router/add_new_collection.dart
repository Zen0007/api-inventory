import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "NEWCOLLECTION";

Future<void> addNewCollection({
  required WebSocketChannel socket,
  required payload,
  required DbCollection collection,
}) async {
  try {
    final String newCollection = payload['category'];

    if (newCollection.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "missing some field",
        },
      ));
      return;
    }

    // add new category to collction
    final result = await collection.findOne(where.exists(newCollection));

    if (result != null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "new category already exists",
        },
      ));
      return;
    }

    // inset empty collction
    await collection.insert({
      newCollection: {},
    });
    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": "success add new category",
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
