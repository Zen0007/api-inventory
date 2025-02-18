import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> verifikasiToken({
  required dynamic payload,
  required WebSocketChannel socket,
  required DbCollection colection,
}) async {
  //this way for chek if  admin token still applies or expired
  try {
    final String? status = payload['token'];
    final token = await colection.findOne(where.eq("token", status));

    if (token != null) {
      return;
    }

    if (status == null) {
      return;
    }

    if (status.isEmpty) {
      return;
    }

    const String secretKey =
        "xr@7(@+mrO)QjA1E_5xXe1@DqC5&VhuhY@*)E)tsUTn5G)USsv^JUGa\$9hSne9RB";

    JWT.verify(status, SecretKey(secretKey));
    socket.sink.add(
      json.encode(
        {
          "endpoint": "VERIFIKASI",
          "status": "VERIFIKASI",
        },
      ),
    );
  } on JWTExpiredException catch (e, s) {
    socket.sink.add(
      json.encode(
        {
          "endpoint": "VERIFIKASI",
          "status": "NOT-VERIFIKASI",
        },
      ),
    );
    print(e);
    print(s);
  } on JWTException catch (e, s) {
    socket.sink.add(
      json.encode(
        {
          "endpoint": "VERIFIKASI",
          "status": "NOT-VERIFIKASI",
        },
      ),
    );
    print(e);
    print(s);
  }
}
