import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> logout(
    {required dynamic payload,
    required WebSocketChannel socket,
    required DbCollection colection}) async {
  try {
    final data = payload['token'];
    await colection.insertOne({"token": data});

    socket.sink.add(json.encode({"message": "lougut success"}));
  } catch (e, s) {
    print(e);
    print(s);
    // return Response(500,
    //     body: json.encode({"message": "internal server error"}));
  }
}
