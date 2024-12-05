import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> login(
    {required dynamic data,
    required WebSocketChannel socket,
    required DbCollection collection}) async {
  try {
    final userName = data['name'];
    final password = data['password'];

    if (userName == null || password == null) {
      socket.sink
          .add(json.encode({"message": "user name or password is field"}));
      return;
    }

    final payload = {
      "username": userName,
      'exp':
          DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
    };

    const String secretKey =
        "xr@7(@+mrO)QjA1E_5xXe1@DqC5&VhuhY@*)E)tsUTn5G)USsv^JUGa\$9hSne9RB";

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(secretKey));

    final findNameAdmin = await collection
        .findOne(where.eq("name", userName).eq("password", password));

    if (findNameAdmin != null) {
      socket.sink.add(
        json.encode(
          {"token": token},
        ),
      );
      return;
    } else {
      socket.sink.add(json.encode({"message": "user not found"}));
      return;
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}
