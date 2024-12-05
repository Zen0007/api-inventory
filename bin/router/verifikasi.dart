import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> verifikasiToken(
    {required dynamic payload,
    required WebSocketChannel socket,
    required DbCollection colection}) async {
  //this way for chek if  admin token still applies

  try {
    final status = payload['status'];
    final token = await colection.findOne(where.eq("token", status));
    if (token != null) {
      socket.sink.add(json.encode({"status": "NOT-VERIFIKASI"}));
    }

    if (status == null) {
      socket.sink.add(json.encode({"status": "NOT-VERIFIKASI"}));
    }

    const String secretKey =
        "xr@7(@+mrO)QjA1E_5xXe1@DqC5&VhuhY@*)E)tsUTn5G)USsv^JUGa\$9hSne9RB";

    JWT.verify(status, SecretKey(secretKey));
    socket.sink.add(json.encode({"status": "VERIFIKASI"}));
  } catch (e, s) {
    print(e);
    print(s);
  }
}
