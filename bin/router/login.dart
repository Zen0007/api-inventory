import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> login({
  required dynamic data,
  required WebSocketChannel socket,
  required DbCollection collection,
  required Db dataBase,
}) async {
  try {
    await dataBase.open();
    final userName = data['name'];
    final password = data['password'];

    if (userName == null || password == null) {
      socket.sink.add(json.encode(
          {"endpoint": "LOGIN", "message": "user name or password is field"}));
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

    final findNameAdmin = await collection.findOne(where
        .eq('$userName.name', userName)
        .eq("$userName.password", password));
    print(userName);
    print(password);
    print(findNameAdmin);
    if (findNameAdmin != null) {
      socket.sink.add(
        json.encode(
          {"endpoint": "LOGIN", "token": token},
        ),
      );
      return;
    } else {
      socket.sink
          .add(json.encode({"endpoint": "LOGIN", "message": "user not found"}));
      return;
    }
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
