import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATAALLCATEGORY";

Future<void> getDataAllCategory({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  int start1 = DateTime.now().millisecond;
  try {
    final data = await collection.find().toList();
    if (data.isEmpty) {
      return; // prevent for exsecute code below
    }

    final List<Map<String, Object>> pipeline = [];
    final watch = collection.watch(pipeline);

    await for (var status in watch) {
      print("is delete ${status.isDelete}");
      print("is insert ${status.isInsert}");
      print("is update ${status.isUpdate}");
      print("event change $status");
      if (status.isUpdate || status.isInsert || status.isDelete) {
        socket.sink.add(
          json.encode(
            {
              endpoint: valueEdnpoint,
              "message": data,
            },
          ),
        );

        int end1 = DateTime.now().millisecond;
        int result1 = start1 - end1;
        print(('${result1 * -1}  Listener databse all category'));

        return;
      }
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

// PUT IN ONPRESS
Future<void> getDataAllCategoryOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  int start1 = DateTime.now().millisecond;
  try {
    final data = await collection.find().toList();
    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": data,
      },
    ));

    int end1 = DateTime.now().millisecond;
    int result1 = start1 - end1;
    print(('$result1 execution code time all Category'));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
