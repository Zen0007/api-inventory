import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> addNewCollection({
  required WebSocketChannel socket,
  required payload,
  required Db dataBase,
  required DbCollection collection,
}) async {
  try {
    await dataBase.open();

    final String newCollection = payload['category'];

    if (newCollection.isEmpty) {
      socket.sink.add(json.encode(
        {
          "endpoint": "ADDNEWCOLLECTION",
          "message": "missing some field",
        },
      ));
      return;
    }

    final result = await collection.findOne(where.exists(newCollection));

    if (result != null) {
      socket.sink.add(json.encode(
        {
          "endpoint": "ADDNEWCOLLECTION",
          "message": "new category already exists",
        },
      ));
      return;
    }

    await collection.insert({
      newCollection: {},
    });
    socket.sink.add(json.encode(
      {
        "endpoint": "ADDNEWCOLLECTION",
        "message": "success add new category",
      },
    ));

    print(newCollection);
    print(result);
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
