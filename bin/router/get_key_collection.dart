import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAALLKEYCATEGORY";

Future<void> getDataAllKeyCategoryOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  int start1 = DateTime.now().millisecond;
  try {
    final data = await collection.find().toList();
    if (data.isEmpty) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": [],
          },
        ),
      );
      return;
    }

    final List<Map> list = [];

    for (var data in data) {
      list.add(
        {
          "key": data.keys.firstWhere(
            (key) => key != "_id",
          ),
          "id": data['_id'].toHexString(),
        },
      );
    }

    socket.sink.add(
      json.encode(
        {
          endpoint: valueEdnpoint,
          "message": list,
        },
      ),
    );

    int end1 = DateTime.now().millisecond;
    int result1 = start1 - end1;
    print(('${result1 * -1} execution code time key'));
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> getAllKeyCategory({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  final data = await collection.find().toList();
  if (data.isEmpty) {
    return; // prevent for exsecute code below
  }

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

    watch.listen((status) async {
      final updateData = await collection.find().toList();
      final List<Map> list = [];

      for (var data in updateData) {
        list.add(
          {
            "key": data.keys.firstWhere(
              (key) => key != "_id",
            ),
            "id": data['_id'].toHexString(),
          },
        );
      }
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": list,
          },
        ),
      );
    });
  } catch (e, s) {
    print(e);
    print(s);
  }
}
