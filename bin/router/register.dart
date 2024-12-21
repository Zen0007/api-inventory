import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "RIGISTER";

Future<void> addNewAdmin({
  dynamic payload,
  required WebSocketChannel socket,
  required DbCollection authAdmin,
  required Db dataBase,
}) async {
  try {
    await dataBase.open();
    final nameNewAdmin = payload['name'];
    final passowrd = payload['password'];

    // for recode who add new admin
    final nameAdminAdd = payload['nameAdd'];

    if (nameNewAdmin == null || passowrd == null) {
      socket.sink.add(json.encode({
        endpoint: valueEdnpoint,
        warning: "user name or password must fill "
      }));
      return;
    }

    final findUser = await authAdmin.findOne(where.eq("name", nameNewAdmin));
    if (findUser != null) {
      socket.sink.add(json.encode({
        endpoint: "REGISTER",
        warning: "name user alredy exists",
      }));
      return;
    }

    await authAdmin.insert({
      nameNewAdmin: {
        "name": nameNewAdmin,
        "password": passowrd,
        "addBy": nameAdminAdd,
      }
    });

    socket.sink.add(json
        .encode({endpoint: valueEdnpoint, "message": "succes add new admin"}));
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}
