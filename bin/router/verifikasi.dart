import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> verifikasiToken({
  required dynamic payload,
  required WebSocketChannel socket,
  required DbCollection colection,
  required Db dataBase,
}) async {
  //this way for chek if  admin token still applies or expired
  try {
    await dataBase.open();
    final String status = payload['token'];
    final token = await colection.findOne(where.eq("token", status));
    if (token != null) {
      socket.sink.add(
          json.encode({"endpoint": "VERIFIKASI", "status": "NOT-VERIFIKASI"}));
      return;
    }

    if (status.isEmpty) {
      socket.sink.add(
          json.encode({"endpoint": "VERIFIKASI", "status": "NOT-VERIFIKASI"}));
      return;
    }

    const String secretKey =
        "xr@7(@+mrO)QjA1E_5xXe1@DqC5&VhuhY@*)E)tsUTn5G)USsv^JUGa\$9hSne9RB";

    JWT.verify(status, SecretKey(secretKey));
    socket.sink
        .add(json.encode({"endpoint": "VERIFIKASI", "status": "VERIFIKASI"}));

    print(status);
  } on JWTUndefinedException catch (e) {
    print(e);
    socket.sink.add(
        json.encode({"endpoint": "VERIFIKASI", "status": "NOT-VERIFIKASI"}));
  } catch (e, s) {
    print(e);
    print(s);
    socket.sink.add(
        json.encode({"endpoint": "VERIFIKASI", "status": "NOT-VERIFIKASI"}));
  } finally {
    await dataBase.close();
  }
}
