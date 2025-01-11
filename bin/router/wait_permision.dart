import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "WAITPERMISION";

Future<void> waithPermitAdmin({
  required WebSocketChannel socket,
  required dynamic payload,
  required DbCollection borrowing,
  required DbCollection pending,
}) async {
  try {
    final String nameUser = payload['name'];
    if (nameUser.isEmpty) {
      return;
    }
    var result = await borrowing.findOne(where.exists(nameUser));

    if (result == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "failed",
        },
      ));
      return;
    }

    // update status in borrow
    await borrowing.updateOne(
      where.id(result['_id']),
      modify.set("$nameUser.status", "pending"),
    );

    // add data from collection borrow to pending
    await pending.insert(result);

    // find data user in collecton
    final updateStatus = await pending.findOne(where.exists(nameUser));

    if (updateStatus == null) {
      socket.sink
          .add(json.encode({endpoint: valueEdnpoint, warning: "failed"}));
      return;
    }

    // update status for collection pending so andmin can noticed user wait granted admin
    await pending.update(where.id(updateStatus["_id"]),
        modify.set("$nameUser.status", "wait permision"));

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": "success",
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
