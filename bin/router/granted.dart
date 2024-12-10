import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GRANTED";

Future<void> granted({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection category,
  required DbCollection pending,
  required DbCollection borrow,
  required DbCollection itemBack,
  required dynamic payload,
}) async {
  try {
    await dataBase.open();

    final adminName = payload['admin'];
    final userName = payload['name'];
    final dateTime = payload['dateTime'];

    final findUserInPending = await pending.findOne(where.exists(userName));
    final findUserBorrow = await borrow.findOne(where.exists(userName));

    if (findUserBorrow == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not found",
        },
      ));
    }

    if (findUserInPending == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not found",
        },
      ));
    }

    await itemBack.insertOne(findUserBorrow!);
    final findUserItemBack = await itemBack.findOne(where.exists(userName));

    if (findUserItemBack == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not found",
        },
      ));
    }

    final items = findUserInPending![userName]['item'];
    await itemBack.updateOne(
      where.id(findUserItemBack!['_id']),
      modify.set(
        "$userName",
        {
          "imageSelfie": items["imageSelfie"],
          "verifikasi": adminName,
          "time": dateTime,
        },
      ),
    );

    print(items);

    if (items == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "failed",
        },
      ));
    }

    // Iterate over each category in the items
    items.forEach((categoryKey, itemMap) {
      itemMap.forEach((itemKey, itemValue) async {
        // Find the item in the category collection and update its status
        final categoryItem = await category.findOne(where.exists(categoryKey));

        if (categoryItem != null) {
          await category.updateOne(
            where.id(categoryItem["_id"]),
            modify.set("$categoryKey.$itemKey.status", "available"),
          );
        }
      });
    });

    final deleteBorrow =
        await borrow.deleteOne(where.id(findUserBorrow['_id']));

    final deletePending =
        await pending.deleteOne(where.id(findUserInPending["_id"]));

    if (deletePending.isSuccess && deleteBorrow.isSuccess) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          "message": "success",
        },
      ));
    } else {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "failed",
        },
      ));
    }
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
