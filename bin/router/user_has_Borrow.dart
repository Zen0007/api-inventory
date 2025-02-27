// ignore: file_names
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "HASBORROW";

Future<void> userHasBorrow({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection collection,
}) async {
  try {
    final String dataUser = payload['name'];
    if (dataUser.isEmpty) {
      return; // prevent if name user in local storage is emptry
    }

    final List<Map<String, Object>> pipeline = [];
    final watch = collection.watch(pipeline);

    watch.listen((status) async {
      final updateData = await collection.findOne(where.exists(dataUser));

      if (status.isUpdate) {
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": updateData,
            },
          ),
        );
      }
      if (status.isInsert) {
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": updateData,
            },
          ),
        );
      }
      if (status.isDelete) {
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": updateData,
            },
          ),
        );
      }
    });
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> userHasBorrowOnce({
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
