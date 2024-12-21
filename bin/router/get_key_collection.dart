import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAALLKEYCATEGORY";

Future<void> getDataAllKeyCategory({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    await dataBase.open();

    final String nameCollection = payload['collection'];

    final data = await collection.find(where.exists(nameCollection)).toList();
    if (data.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "data collection Is empty ",
        },
      ));
      return;
    }

    final List<Map> list = [];

    for (var data in data) {
      list.add({
        "key": data.keys.firstWhere(
          (key) => key != "_id",
        ),
        "id": data['_id']['\$oid'],
      });
    }

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": list,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
