import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "DELETECATEGORY";

Future<void> deleteCategory({
  required WebSocketChannel socket,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    final String nameCategory = payload['category'];

    if (nameCategory.isEmpty) {
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
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "category not exist",
        },
      ));
      return;
    }
    findIndex.forEach((categoryName, value) {
      if (categoryName != '_id') {
        if (value.length >= 5) {
          socket.sink.add(
            json.encode(
              {
                endpoint: valueEdnpoint,
                warning:
                    "documnets value is not safe for delete make sure value less from 5",
              },
            ),
          );
        }

        return;
      }
    });

    final deleteItem = await collection.deleteOne(
      where.id(findIndex["_id"]),
    );

    if (deleteItem.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEdnpoint,
            "message": "success to delete category",
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
