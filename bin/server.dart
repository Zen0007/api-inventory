import 'dart:developer' as dev;
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
  channel.add(socket);
  dev.log("Active connections: ${channel.length}");
  int start1 = DateTime.now().millisecondsSinceEpoch;
  final categoryColection = dataBase.collection('category');
  final authAdmin = dataBase.collection('authAdmin');
  final borrowing = dataBase.collection('borrowing');
  final itemBack = dataBase.collection('returnItem');
  final pending = dataBase.collection('pendingReturn');
  final expiredToken = dataBase.collection('expiredToken');
  try {
    socket.stream.listen(
      (event) async {
        print("event handleWs $event");
        var data = json.decode(event);
        final endpoint = data['endpoint'];
        final payload = data['data'];

        switch (endpoint) {
          case "register":
            await addNewAdmin(
              payload: payload,
              socket: socket,
              authAdmin: authAdmin,
            );
            break;
          case "login":
            await login(
              collection: authAdmin,
              data: payload,
              socket: socket,
            );
            break;
          case "logout":
            await logout(
              payload: payload,
              socket: socket,
              colection: expiredToken,
            );
            break;
          case "verifikasi":
            await verifikasiToken(
              colection: expiredToken,
              payload: payload,
              socket: socket,
            );
            break;
          case "newCollection":
            await addNewCollection(
              socket: socket,
              payload: payload,
              collection: categoryColection,
            );
            break;
          case "newItem":
            await addItemToInventory(
              socket: socket,
              payload: payload,
              dataBase: dataBase,
              collection: categoryColection,
            );
            break;
          case "deleteItem":
            await deleteItem(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case "deleteCategory":
            await deleteCategory(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case 'deleteUserGratend':
            await deleteUserGratend(
              socket: socket,
              collection: itemBack,
              payload: payload,
            );
            break;
          case "updateStatusItem":
            await updateStatusItem(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case "borrowing":
            await borrowingItem(
              socket: socket,
              dataBase: dataBase,
              collection: borrowing,
              payload: payload,
            );
            break;
          case "checkUserBorrow":
            await checkUserIsBorrow(
              socket: socket,
              payload: payload,
              collection: borrowing,
            );
            break;
          case "hasBorrow":
            await userHasBorrow(
              socket: socket,
              payload: payload,
              collection: borrowing,
            );
            break;
          case "hasBorrowOnce":
            await userHasBorrowOnce(
              socket: socket,
              payload: payload,
              collection: borrowing,
            );
            break;
          case "waitPermision":
            await waithPermitAdmin(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
              pending: pending,
            );
            break;
          case "granted":
            await granted(
              socket: socket,
              category: categoryColection,
              pending: pending,
              borrow: borrowing,
              itemBack: itemBack,
              payload: payload,
            );
            break;

          case "getDataBorrow":
            await getDataBorrow(
              socket: socket,
              collection: borrowing,
            );
            break;
          case "getDataBorrowOnce":
            await getDataBorrowOnce(
              socket: socket,
              collection: borrowing,
            );
            break;
          case "getDataPending":
            await getDataPending(
              socket: socket,
              collection: pending,
            );
            break;
          case "getDataPendingOnce":
            await getDataPendingOnce(
              socket: socket,
              collection: pending,
            );
            break;
          case "getDataAllCollection":
            await getDataAllCategory(
              socket: socket,
              collection: categoryColection,
            );
            break;
          case "getDataAllCollectionOnce":
            await getDataAllCategoryOnce(
              socket: socket,
              collection: categoryColection,
            );
            break;
          case "getDataCollectionAvaileble":
            await getDataCategoryAvaileble(
              socket: socket,
              collection: categoryColection,
            );
            break;
          case "getDataCollectionAvailebleOnce":
            await getDataCategoryAvailebleOnce(
              socket: socket,
              collection: categoryColection,
            );
            break;
          case "getDataGranted":
            await getDataGranted(
              socket: socket,
              collection: itemBack,
            );
            break;
          case "getDataGrantedOnce":
            await getDataGrantedOnce(
              socket: socket,
              collection: itemBack,
            );
            break;
          case "getAllKeyCategory":
            await getAllKeyCategory(
              collection: categoryColection,
              socket: socket,
            );
            break;
          case "getAllKeyCategoryOnce":
            await getDataAllKeyCategoryOnce(
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

        int end1 = DateTime.now().millisecondsSinceEpoch;
        int result1 = start1 - end1;
        print(('$result1 execution code time handelWs'));
      },
      onDone: () {
        channel.remove(socket);
        dev.log("Done Connection");
      },
      onError: (e) {
        channel.remove(socket);
        dev.log("Active connections on error $e");
        socket.sink.close();
      },
      cancelOnError: true,
    );
  } catch (e, s) {
    dev.log("Connections Is : $e");
    dev.log("Connections Is : $s");
    print(s);
  }
}

void main(List<String> args) async {
  try {
    final int port = 8080;
    final server = await HttpServer.bind('127.0.0.1', port);
    print('webSocker listening on ws:/$server');
    print("port ${server.address}");

    final Db dataBase = Db('mongodb://localhost:27017/inventory');
    await dataBase.open();
    await for (HttpRequest request in server) {
      if (request.uri.path == '/ws') {
        final socket = await WebSocketTransformer.upgrade(request);
        final chanel = IOWebSocketChannel(socket);

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
