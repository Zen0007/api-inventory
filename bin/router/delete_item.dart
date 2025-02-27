import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "DELETEITEM";

Future<void> deleteItem({
  required WebSocketChannel socket,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    int start1 = DateTime.now().millisecond;
    final String nameCategory = payload['category'];
    final String indexItem = payload['index'];

    if (nameCategory.isEmpty || indexItem.isEmpty) {
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

    final findIndex = await collection.findOne(where.exists(nameCategory));
    if (findIndex == null) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "failde to delete item",
          },
        ),
      );
      return;
    }
    if (!findIndex[nameCategory].containsKey(indexItem)) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "failde to delete item",
          },
        ),
      );
      return;
    }
    var update = {
      '\$unset': {'$nameCategory.$indexItem': ''}
    };
    final deleteItem =
        await collection.updateOne(where.id(findIndex["_id"]), update);

    if (deleteItem.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "success to delete item $indexItem",
          },
        ),
      );
      int end1 = DateTime.now().millisecond;
      int result1 = start1 - end1;
      print(('${result1 * -1} execution code time Delete item'));
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
