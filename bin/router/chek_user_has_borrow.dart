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
  required Db dataBase,
  required DbCollection collection,
}) async {
  try {
    await dataBase.open();

    final dataUser = payload['name'];
    final result = await collection.findOne(where.exists(dataUser));

    if (result == null) {
      socket.sink.add(json.encode({endpoint: valueEdnpoint, "user": null}));
    }

    socket.sink.add(json.encode({endpoint: valueEdnpoint, "user": result}));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
