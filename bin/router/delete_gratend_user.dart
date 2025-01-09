import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "FREEDATAGRATEND";

Future<void> deleteUserGratend({
  required WebSocketChannel socket,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    final String nameUser = payload['nameUser'];

    if (nameUser.isEmpty) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "missing some field",
          },
        ),
      );
      return;
    }

    final findIndex = await collection.findOne(where.exists(nameUser));

    final deleteItem = await collection.updateOne(
      where.id(findIndex!["_id"]),
      modify.unset(nameUser),
    );

    if (deleteItem.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "success to delete item",
          },
        ),
      );
      return;
    } else {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "not item delete",
          },
        ),
      );
    }
  } catch (e, s) {
    print(e);
    print(s);
    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        warning: {"error": "$e", "StackTrace": "$s"},
      },
    ));
  }
}
