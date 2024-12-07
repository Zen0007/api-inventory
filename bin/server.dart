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

final Set<WebSocketChannel> channel = {};

void handleWebSocket(WebSocketChannel socket, Db dataBase) async {
  final categoryColection = dataBase.collection('category');
  final authAdmin = dataBase.collection('authAdmin');
  final borrowing = dataBase.collection('borrowing');
  final itemBack = dataBase.collection('returnItem');
  final pendingItem = dataBase.collection('pendingReturn');
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
        case "addNewCollection":
          addNewCollection(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            collection: categoryColection,
          );
          break;
        case "addNewItem":
          addItemToInventory(
            socket: socket,
            payload: payload,
            dataBase: dataBase,
            collection: categoryColection,
          );
          break;
        default:
          socket.sink.add(json.encode({"error": "endpoint not found"}));
      }
    }, onDone: () {
      channel.remove(socket);
      socket.sink.close();
      print("is close");
    }, onError: (e) {
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

// Future<Response> deleteItem(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final nameCategory = data['category'];
//     final item = data['item'];

//     db['category'][nameCategory].remove(item);
//     return Response(200,
//         body: json.encode({"message": "success to delete item"}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "internal server error"}));
//   }
// }

// Future<Response> updateStatusItem(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final category = data['category'];
//     final indexItem = data['index'];
//     final newStatus = data['status'];

//     db['category'][category][indexItem]['status'] = newStatus;

//     print(db['category']);
//     return Response(200,
//         body: json.encode(
//           {
//             "message": "success update status",
//           },
//         ));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "internal server error"}));
//   }
// }


// Future<Response> borrowingItem(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final nameUser = data['name'];
//     final classUser = data['class'];
//     final nisnUser = data['nisn'];
//     final nameTeacher = data['teacher'];
//     final indexItem = data['item'];
//     final collection = data['collection'];
//     final imageSelfie = data['imageSelfie'];
//     final imageNisn = data['imageNisn'];
//     if (!data.containsKey('name') ||
//         !data.containsKey('class') ||
//         !data.containsKey('nisn') ||
//         !data.containsKey('teacher') ||
//         !data.containsKey('imageSelfie') ||
//         !data.containsKey('imageNisn')) {
//       return Response(404,
//           body: json.encode({"message": "missing some field"}));
//     }

//     if (db['borrowing'].containsKey(nameUser)) {
//       return Response(404,
//           body: json.encode(
//             {
//               "message": "still borrow item pleas return item alredy borrow",
//             },
//           ));
//     }

//     if (!db['category'][collection].containsKey(indexItem)) {
//       return Response(404,
//           body: json.encode(
//             {"message": 'the name index not found in colection $collection'},
//           ));
//     }
//     final borrowItem = db['category'][collection][indexItem];

//     final Map<String, Object> borrow = {
//       "status": "borrow",
//       "userName": nameUser,
//       "class": classUser,
//       "nameTeacher": nameTeacher,
//       "nisn": nisnUser,
//       "imageNisn": imageNisn ?? '-',
//       "imageSelfie": imageSelfie ?? '-',
//       "item": {}
//     };
//     db['borrowing'][nameUser] = borrow;

//     // Add the item to the user's borrowing collection without replacing existing items
//     db['borrowing'][nameUser]['item'][collection] ??= {};
//     db['borrowing'][nameUser]['item'][collection][indexItem] = borrowItem;
//     print(db['borrowing']);
//     return Response(200, body: json.encode({"userBorrow": nameUser}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500, body: json.encode({"message": "$e", "s": "$s"}));
//   }
// }

// Future<Response> checkUserIsBorrow(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);
//     final dataUser = data['name'];

//     if (!db['borrowing'].containsKey(dataUser)) {
//       return Response(404, body: json.encode({"user": "not"}));
//     }
//     final user = db['borrowing'][dataUser];
//     print(db['borrowing']);
//     return Response(200, body: json.encode({"user": user}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "internal server error"}));
//   }
// }

// Future<Response> waithPermitAdmin(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final nameUser = data['nameUser'];

//     final pending = db['borrowing'][nameUser];
//     db['borrowing'][nameUser]['status'] = "pending";

//     db['pending'][nameUser] = pending;
//     db['pending'][nameUser]['status'] = 'wait permit';

//     print(db['pending']);
//     return Response(200, body: json.encode({"message": db['pending']}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "intenal server error"}));
//   }
// }

// Future<Response> granted(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final adminName = data['admin'];
//     final userName = data['nameUser'];
//     final dateTime = data['dateTime'];

//     final listItem = db['borrowing'][userName]["item"];
//     final pendingData = db['pending'][userName];
//     print(db['borrowing'][userName]["item"]);
//     db['itemBack'][userName] = pendingData;
//     db['itemBack'][userName]['verifikasi'] = adminName;
//     db['itemBack'][userName]['time'] = dateTime;
//     db['itemBack'][userName] = {
//       "item": listItem,
//     };
//     print("$listItem   -----");
//     db['borrowing'][userName]["item"].forEach((key, value) {
//       value.forEach((itemKey, itemValue) {
//         if (db['category'][key] != null) {
//           db['category'][key][itemKey]['status'] = "available";
//         }
//       });
//     });
//     print(pendingData);

//     return Response(
//       200,
//       body: json.encode(
//         {
//           "message": db['itemBack'][userName],
//           "item": db['borrowing'][userName]['item']
//         },
//       ),
//     );
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500, body: json.encode({"message": "$e", "s": "$s"}));
//   }
// }
