import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAPENDING";

Future<void> getDataPending({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final pipeline = [
      {
        "\$match": {
          'operationType': {
            '\$in': ['insert', 'update', 'delete']
          }
        }
      }
    ];
    final watch = collection.watch(pipeline);

    watch.listen(
      (status) async {
        final updateData = await collection.find().toList();
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": updateData,
            },
          ),
        );
      },
    );
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> getDataPendingOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final getData = await collection.find().toList();
    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": getData,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
