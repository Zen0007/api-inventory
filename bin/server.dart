import 'dart:io';
import 'dart:convert';
import 'router/login.dart';
import 'router/logout.dart';
import 'router/granted.dart';
import 'router/register.dart';
import 'router/verifikasi.dart';
import 'router/add_new_item.dart';
import 'router/delete_item.dart';
import 'router/delete_category.dart';
import 'router/delete_gratend_user.dart';
import 'router/update_status.dart';
import 'router/borrowing_user.dart';
import 'router/wait_permision.dart';
import 'router/get_user_granted.dart';
import 'router/get_borrow_data.dart';
import 'router/get_pending_data.dart';
import 'router/get_key_collection.dart';
import 'router/get_category_data.dart';
import 'router/add_new_collection.dart';
import 'router/chek_user_has_borrow.dart';
import 'router/get_data_all_category.dart';
import 'router/user_has_borrow.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
      print(event);
      var data = json.decode(event);
      final endpoint = data['endpoint'];
      final payload = data['data'];

      switch (endpoint) {
        case "register":
          addNewAdmin(
            payload: payload,
            socket: socket,
            authAdmin: authAdmin,
          );
          break;
        case "login":
          login(
            collection: authAdmin,
            data: payload,
            socket: socket,
          );
          break;
        case "logout":
          logout(
            payload: payload,
            socket: socket,
            colection: expiredToken,
          );
          break;
        case "verifikasi":
          verifikasiToken(
            colection: expiredToken,
            payload: payload,
            socket: socket,
          );
          break;
        case "newCollection":
          addNewCollection(
            socket: socket,
            payload: payload,
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
            collection: categoryColection,
            payload: payload,
          );
          break;
        case "deleteCategory":
          deleteCategory(
            socket: socket,
            collection: categoryColection,
            payload: payload,
          );
          break;
        case 'deleteUserGratend':
          deleteUserGratend(
            socket: socket,
            collection: itemBack,
            payload: payload,
          );
          break;
        case "updateStatusItem":
          updateStatusItem(
            socket: socket,
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
            collection: borrowing,
          );
          break;
        case "hasBorrow":
          hasBorrow(
            socket: socket,
            payload: payload,
            collection: borrowing,
          );
          break;
        case "hasBorrowOnce":
          hasBorrowOnce(
            socket: socket,
            payload: payload,
            collection: borrowing,
          );
          break;
        case "waitPermision":
          waithPermitAdmin(
            socket: socket,
            payload: payload,
            borrowing: borrowing,
            pending: pending,
          );
          break;
        case "granted":
          granted(
            socket: socket,
            category: categoryColection,
            pending: pending,
            borrow: borrowing,
            itemBack: itemBack,
            payload: payload,
          );
          break;
        case "getDataAllCollection":
          getDataAllCategory(
            socket: socket,
            collection: categoryColection,
          );
          break;
        case "getDataAllCollectionOnce":
          getDataAllCategoryOnce(
            socket: socket,
            collection: categoryColection,
          );
          break;
        case "getDataBorrow":
          getDataBorrow(
            socket: socket,
            collection: borrowing,
          );
          break;
        case "getDataBorrowOnce":
          getDataBorrowOnce(
            socket: socket,
            collection: borrowing,
          );
          break;
        case "getDataPending":
          getDataPending(
            socket: socket,
            collection: pending,
          );
          break;
        case "getDataPendingOnce":
          getDataPendingOnce(
            socket: socket,
            collection: pending,
          );
          break;
        case "getDataCollectionAvaileble":
          getDataCategoryAvaileble(
            socket: socket,
            collection: categoryColection,
          );
          break;
        case "getDataCollectionAvailebleOnce":
          getDataCategoryAvailebleOnce(
            socket: socket,
            collection: categoryColection,
          );
          break;
        case "getDataGranted":
          getDataGranted(
            socket: socket,
            collection: itemBack,
          );
          break;
        case "getDataGrantedOnce":
          getDataGrantedOnce(
            socket: socket,
            collection: itemBack,
          );
          break;
        case "getAllKeyCategory":
          getDataAllKeyCategory(
            socket: socket,
            collection: categoryColection,
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
  try {
    final server = await HttpServer.bind('127.0.0.1', 8080);
    print('webSocker listening on ws:/$server');

    final Db dataBase = Db('mongodb://localhost:27017/inventory');
    await dataBase.open();
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

    print("done");
  } catch (e, s) {
    print(e);
    print(s);
  }
}
