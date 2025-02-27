import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GRANTED";

Future<void> granted({
  required WebSocketChannel socket,
  required DbCollection category,
  required DbCollection pending,
  required DbCollection borrow,
  required DbCollection itemBack,
  required dynamic payload,
}) async {
  try {
    final adminName = payload['admin'];
    final userName = payload['name'];
    final dateTime = payload['dateTime'];

    final findUserInPending = await pending.findOne(where.exists(userName));
    final findUserBorrow = await borrow.findOne(where.exists(userName));

    if (findUserBorrow == null || findUserInPending == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not found",
        },
      ));
      return;
    }

    /*
        this code insert data form collection pending 
    */
    await itemBack.insertOne(findUserInPending);

    // get data in collection itemBack
    final findUserItemBack = await itemBack.findOne(where.exists(userName));

    if (findUserItemBack == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not found",
        },
      ));
      return;
    }

    //    this get data items fro update status items
    final itemsUpdateStatus = findUserItemBack[userName]['items'];

    /* 
    this code for interation items was borrow user and update
    status in intems collection category to availeble
    */
    for (var status in itemsUpdateStatus) {
      final categoryName = status['category'];
      final index = status['index'];

      //    this code to get data in collection category
      final categoryItem = await category.findOne(where.exists(categoryName));

      if (categoryItem != null) {
        // update status items in collection category
        await category.updateOne(
          where
              .id(categoryItem["_id"])
              .eq("$categoryName.$index", {"\$exists": true}),
          modify.set("$categoryName.$index.status", "available"),
        );
      }
    }

    /* update status user in Collection items Back
      update time and add admin 
    */
    final update = {
      '\$set': {
        '$userName.status': "has return",
        '$userName.time': "$dateTime",
        '$userName.admin': "$adminName",
      }
    };

    await itemBack.updateMany(where.id(findUserItemBack['_id']), update);

    /*
        for saving resources so data user in collction borrow 
        and in collection pending must be clean 
    */
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
      return;
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
  }
}
