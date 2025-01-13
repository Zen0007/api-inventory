import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "HASBORROW";

Future<void> hasBorrow({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection collection,
}) async {
  try {
    final String dataUser = payload['name'];
    if (dataUser.isEmpty) {
      return;
    }
    final result = await collection.findOne(where.exists(dataUser));

    if (result != null) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": result,
          },
        ),
      );
      return;
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}
