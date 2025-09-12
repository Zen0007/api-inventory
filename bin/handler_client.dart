import 'dart:developer' as dev;
import 'dart:convert';
import 'router/pending.dart';
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
import 'router/get_user_granted.dart';
import 'router/get_borrow_data.dart';
import 'router/get_pending_data.dart';
import 'router/get_key_collection.dart';
import 'router/get_category_data.dart';
import 'router/add_new_collection.dart';
import 'router/get_data_all_category.dart';
import 'router/user_has_borrow.dart';
import 'package:mongo_pool/mongo_pool.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final Set<WebSocketChannel> channel = {};

void handleWebSocket(
    WebSocketChannel socket, MongoDbPoolService pooling) async {
  final Db dataBase = await pooling.acquire();
  try {
    channel.add(socket);
    int start1 = DateTime.now().millisecondsSinceEpoch;
    final categoryColection = dataBase.collection('category');
    final authAdmin = dataBase.collection('authAdmin');
    final borrowing = dataBase.collection('borrowing');
    final itemBack = dataBase.collection('returnItem');
    final pending = dataBase.collection('pendingReturn');
    final expiredToken = dataBase.collection('expiredToken');

    channel.last.stream.listen(
      (event) async {
        final data = json.decode(event);
        final endpoint = data['endpoint'];
        final payload = data['data'];

        print("         \t $endpoint");
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
              authAdmin: authAdmin,
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
          case "newCollection": // it work so not have call endpoint for get data
            getAllKeyCategory(collection: categoryColection, socket: socket);

            await addNewCollection(
              socket: socket,
              payload: payload,
              collection: categoryColection,
            );
            break;
          case "newItem": // it work so not have call endpoint for get data
            getDataCategoryAvaileble(
              socket: socket,
              collection: categoryColection,
            );
            getDataAllCategory(socket: socket, collection: categoryColection);

            await addItemToInventory(
              socket: socket,
              payload: payload,
              collection: categoryColection,
            );
            break;
          case "deleteItem": // it work so not have call endpoint for get data
            getDataCategoryAvaileble(
                socket: socket, collection: categoryColection);
            getDataAllCategory(socket: socket, collection: categoryColection);

            await deleteItem(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case "deleteCategory": // it work so not have call endpoint for get data
            getAllKeyCategory(collection: categoryColection, socket: socket);

            await deleteCategory(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case 'deleteUserGratend': // it work so not have call endpoint for get data
            getDataGranted(
              socket: socket,
              itemBack: itemBack,
            );

            await deleteUserGratend(
              socket: socket,
              collection: itemBack,
              payload: payload,
            );
            break;
          case "updateStatusItem": // it work so not have call endpoint for get data
            getDataCategoryAvaileble(
              socket: socket,
              collection: categoryColection,
            );
            getDataAllCategory(
              socket: socket,
              collection: categoryColection,
            );

            await updateStatusItem(
              socket: socket,
              collection: categoryColection,
              payload: payload,
            );
            break;
          case "borrowing": // it work so not have call endpoint for get data
            getDataBorrow(
              socket: socket,
              borrowing: borrowing,
            );

            await borrowingItem(
              socket: socket,
              collection: borrowing,
              payload: payload,
            );

            break;
          case "waitPermision": // it work so not have call endpoint for get data
            getDataPending(
              socket: socket,
              pending: pending,
            );
            userHasBorrow(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
            );
            getDataBorrow(
              socket: socket,
              borrowing: borrowing,
            );

            await waithPermitAdmin(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
              pending: pending,
            );

            break;
          case "granted": // it work so not have call endpoint for get data
            getDataPending(
              socket: socket,
              pending: pending,
            );
            getDataBorrow(
              socket: socket,
              borrowing: borrowing,
            );
            getDataGranted(
              socket: socket,
              itemBack: itemBack,
            );
            userHasBorrow(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
            );

            await granted(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
              categoryColection: categoryColection,
              itemBack: itemBack,
              pending: pending,
            );
            break;

          case "getDataBorrowOnce":
            await getDataBorrowOnce(
              socket: socket,
              borrowing: borrowing,
            );
            break;

          case "getDataPendingOnce":
            await getDataPendingOnce(
              socket: socket,
              pending: pending,
            );

          case "getDataAllCollectionOnce":
            await getDataAllCategoryOnce(
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

          case "getDataGrantedOnce":
            await getDataGrantedOnce(
              socket: socket,
              itemBack: itemBack,
            );
            break;

          case "getAllKeyCategoryOnce":
            await getDataAllKeyCategoryOnce(
              socket: socket,
              collection: categoryColection,
            );
            break;

          case "hasBorrowOnce":
            await userHasBorrowOnce(
              socket: socket,
              payload: payload,
              borrowing: borrowing,
            );
            break;
          // case "getDataBorrow":
          //   await getDataBorrow(
          //     socket: socket,
          //     collection: borrowing,
          //   );
          //   break;
          // case "checkUserBorrow":
          //   await checkUserIsBorrow(
          //     socket: socket,
          //     payload: payload,
          //     collection: borrowing,
          //   );
          //   break;
          // case "hasBorrow":
          //   await userHasBorrow(
          //     socket: socket,
          //     payload: payload,
          //     collection: borrowing,
          //   );
          //   break;
          // case "getAllKeyCategory":
          //   await getAllKeyCategory(
          //     collection: categoryColection,
          //     socket: socket,
          //   );
          //   break;
          // case "getDataGranted":
          //   await getDataGranted(
          //     socket: socket,
          //     collection: itemBack,
          //   );
          //   break;
          // case "getDataCollectionAvaileble":
          //   await getDataCategoryAvaileble(
          //     socket: socket,
          //     collection: categoryColection,
          //   );
          //   break;
          // case "getDataAllCollection":
          //   getDataAllCategory(
          //     socket: socket,
          //     collection: categoryColection,
          //   );
          //   break;
          // case "getDataPending":
          //   await getDataPending(
          //     socket: socket,
          //     collection: pending,
          //   );
          //   break;
          default:
            socket.sink.add(
              json.encode(
                {
                  "endpoint": "ERROR",
                  "error": "endpoint not found",
                },
              ),
            );
        }

        int end1 = DateTime.now().millisecondsSinceEpoch;
        int result1 = start1 - end1;
        print(('$result1 execution code time handelWs'));

        dev.log("Active connections: ${channel.length}");
      },
      onDone: () {
        dev.log("client close");
        channel.clear();
      },
      onError: (e) {
        dev.log("on error $e");
        channel.clear();
      },
    );
  } catch (e) {
    dev.log("error $e");
  } finally {
    dev.log("connect is complate");
    print("connections client is complate");
    pooling.release(dataBase);
  }
}

Future<void> initializePooling(MongoDbPoolService service) async {
  try {
    await service.initialize();
  } on Exception catch (e, s) {
    print(e);
    print(s);
  }
}
