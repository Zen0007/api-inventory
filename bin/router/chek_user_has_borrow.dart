//for screen user if has borrow in web user can see item he has borrow
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "CHECKUSER";

Future<void> checkUserIsBorrow({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection collection,
}) async {
  try {
    final String dataUser = payload['name'];
    if (dataUser.isEmpty) {
      return; // prevent if name user in local storage is emptry
    }
    final result = await collection.findOne(where.exists(dataUser));

    if (result != null) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "HASBORROW",
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
