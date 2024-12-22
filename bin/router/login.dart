import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "LOGIN";

Future<void> login({
  required dynamic data,
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final userName = data['name'];
    final password = data['password'];
    print(userName);
    print(password);
    if (userName == null || password == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user name or password is field",
        },
      ));
      return;
    }
    final findUser = await collection.findOne(where.exists(userName));

    if (findUser == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "user not exists",
        },
      ));
      return;
    }

    if (findUser[userName]['password'] != password) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "password is wrong",
        },
      ));
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

    if (findUser[userName]['password'] == password) {
      socket.sink.add(
        json.encode(
          {endpoint: valueEdnpoint, "message": token},
        ),
      );
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}
