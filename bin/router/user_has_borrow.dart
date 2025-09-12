// ignore: file_names
import 'dart:convert';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "HASBORROW";

Future<void> userHasBorrow({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection borrowing,
}) async {
  try {
    final String dataUser = payload['name'];
    if (dataUser.isEmpty) {
      return; // prevent if name user in local storage is emptry
    }

    final pipeline = [
      {
        "\$match": {
          'operationType': {
            '\$in': ['insert', 'update', 'delete']
          }
        }
      }
    ];
    final watch = borrowing.watch(pipeline);

    watch.listen((status) async {
      final updateData = await borrowing.findOne(where.exists(dataUser));

      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": updateData,
          },
        ),
      );
    });
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> userHasBorrowOnce({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection borrowing,
}) async {
  try {
    final String dataUser = payload['name'];
    if (dataUser.isEmpty) {
      return; // prevent if name user in local storage is emptry
    }
    final result = await borrowing.findOne(where.exists(dataUser));

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
