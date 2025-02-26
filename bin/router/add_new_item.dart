import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'get_data_all_category.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "NEWITEM";

Future<void> addItemToInventory({
  required WebSocketChannel socket,
  dynamic payload,
  required DbCollection collection,
}) async {
  int start1 = DateTime.now().millisecond;
  try {
    final String nameCategory = payload['category'];
    final String nameItem = payload['name'];
    final String label = payload['label'];
    final List image = payload['image'];

    if (nameCategory.isEmpty || nameItem.isEmpty || label.isEmpty) {
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

    // find category
    final result = await collection.findOne(where.exists(nameCategory));

    if (result == null) {
      print("the category is not exists ");
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "category name is not found",
          },
        ),
      );
      return;
    }

    // check last index in collection
    List<int> lastIndex = (result[nameCategory] as Map<String, dynamic>)
        .keys
        .map((key) => int.parse(key))
        .toList();

    int lastKey =
        lastIndex.isEmpty ? 0 : lastIndex.reduce((a, b) => a > b ? a : b);

    // Menentukan key baru yang increment
    String newKey = "${lastKey + 1}";

    // Menambahkan item baru dengan key increment
    final updateCollection = await collection.updateOne(
      where.id(result['_id']),
      modify.set(
        "$nameCategory.$newKey",
        {
          'name': nameItem,
          'Label': label,
          "status": "available",
          'image': image,
        },
      ),
    );

    if (updateCollection.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            "endpoint": "ADDNEWITEM",
            "message": "success add new item",
          },
        ),
      );

      int end1 = DateTime.now().millisecond;
      int result1 = start1 - end1;
      print(('${result1 * -1} execution code time add new item'));
      return;
    } else {
      print('No document found with that _id or no changes made');
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            warning: "not category found ",
          },
        ),
      );
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}
