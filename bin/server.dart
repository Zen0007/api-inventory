import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'router/register.dart';
import 'router/login.dart';
import 'router/logout.dart';
import 'router/verifikasi.dart';
import 'router/add_new_collection.dart';
import 'router/add_new_item.dart';
import 'router/delete_item.dart';
import 'router/update_status.dart';
import 'router/borrowing_user.dart';
import 'router/chek_user_has_borrow.dart';
import 'router/wait_permision.dart';
import 'router/granted.dart';

final Set<WebSocketChannel> channel = {};

void handleWebSocket(WebSocketChannel socket, Db dataBase) async {
  final categoryColection = dataBase.collection('category');
  final authAdmin = dataBase.collection('authAdmin');
  final borrowing = dataBase.collection('borrowing');
  final itemBack = dataBase.collection('returnItem');
  final pending = dataBase.collection('pendingReturn');
  final expiredToken = dataBase.collection('expiredToken');
  try {
    socket.stream.listen((event) {
      var data = json.decode(event);
      final endpoint = data['endpoint'];
      final payload = data['data'];

      switch (endpoint) {
        case "register":
          addNewAdmin(
            payload: payload,
            socket: socket,
            authAdmin: authAdmin,
            dataBase: dataBase,
          );
          break;
        case "login":
          login(
            collection: authAdmin,
            data: payload,
            socket: socket,
            dataBase: dataBase,
          );
          break;
        case "logout":
          logout(
            payload: payload,
            socket: socket,
            colection: expiredToken,
            dataBase: dataBase,
          );
          break;
        case "verifikasi":
          verifikasiToken(
            colection: expiredToken,
            payload: payload,
            socket: socket,
            dataBase: dataBase,
          );
          break;
        case "newCollection":
          addNewCollection(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            collection: categoryColection,
          );
          break;
        case "newItem":
          addItemToInventory(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            collection: categoryColection,
          );
          break;
        case "deleteItem":
          deleteItem(
              socket: socket,
              dataBase: dataBase,
              collection: categoryColection,
              payload: payload);
          break;
        case "updateStatusItem":
          updateStatusItem(
            socket: socket,
            dataBase: dataBase,
            collection: categoryColection,
            payload: payload,
          );
          break;
        case "borrowing":
          borrowingItem(
            socket: socket,
            dataBase: dataBase,
            collection: borrowing,
            payload: payload,
          );
          break;
        case "checkUserBorrow":
          checkUserIsBorrow(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            collection: borrowing,
          );
          break;
        case "waitPermision":
          waithPermitAdmin(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            borrowing: borrowing,
            pending: pending,
          );
          break;
        case "granted":
          granted(
            socket: socket,
            dataBase: dataBase,
            category: categoryColection,
            pending: pending,
            borrow: borrowing,
            itemBack: itemBack,
            payload: payload,
          );
          break;
        default:
          socket.sink.add(json.encode(
            {
              "endpoint": "ERROR",
              "error": "endpoint not found",
            },
          ));
      }
    }, onDone: () {
      channel.remove(socket);
      socket.sink.close();
      print("is close");
    }, onError: (e) {
      channel.remove(socket);
      socket.sink.close();
      print('on error');
      print(e);
    });
  } catch (e, s) {
    print(e);
    print(s);
  }
}

void main(List<String> args) async {
  final server = await HttpServer.bind('127.0.0.1', 8080);
  print('webSocker listening on ws:/$server');

  final String url = 'mongodb://localhost:27017/inventory';
  final dataBase = Db(url);

  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      final socket = await WebSocketTransformer.upgrade(request);
      final chanel = IOWebSocketChannel(socket);
      channel.add(chanel);
      handleWebSocket(chanel, dataBase);
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
    }
  }
}

// Future<Response> deleteBorrowingUser(Request req) async {
//   try {
//     return Response(200,
//         body: json.encode({"message": "success delete user "}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "internal server error"}));
//   }
// }







