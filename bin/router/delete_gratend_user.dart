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
    if (findIndex == null) {
      socket.sink.add(json.encode({
        endpoint: valueEdnpoint,
        warning: "user  not exist",
      }));
      return;
    }
    print(findIndex);
    final deleteItem = await collection.deleteOne(where.id(findIndex["_id"]));

    if (deleteItem.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "success to delete user",
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
