import 'dart:convert';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAGRANTED";

Future<void> getDataGranted(
    {required WebSocketChannel socket, required DbCollection itemBack}) async {
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
    final watch = itemBack.watch(pipeline);

    watch.listen(
      (status) async {
        final updateData = await itemBack.find().toList();
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

Future<void> getDataGrantedOnce({
  required WebSocketChannel socket,
  required DbCollection itemBack,
}) async {
  try {
    final getData = await itemBack.find().toList();
    socket.sink.add(
      json.encode(
        {
          endpoint: valueEdnpoint,
          "message": getData,
        },
      ),
    );
  } catch (e, s) {
    print(e);
    print(s);
  }
}
