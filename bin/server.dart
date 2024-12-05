import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'router/register.dart';
import 'router/login.dart';
import 'router/logout.dart';

void handleWebSocket(WebSocketChannel socket) async {
  final String url = 'mongodb://localhost:27017/inventory';

  final dataBase = Db(url);
  final itemColection = dataBase.collection('category');
  final authAdmin = dataBase.collection('authAdmin');
  final borrowing = dataBase.collection('borrowing');
  final itemBack = dataBase.collection('returnItem');
  final pendingItem = dataBase.collection('pendingReturn');
  final expiredToken = dataBase.collection('expiredToken');
  await dataBase.open();
  try {
    await dataBase.open();

    socket.stream.listen(
      (event) {
        var data = json.decode(event);
        final endpoint = data['endpoint'];
        final payload = data['data'];

        switch (endpoint) {
          case "register":
            addNewAdmin(payload, socket, authAdmin);
            break;
          case "login":
            login(collection: authAdmin, data: payload, socket: socket);
            break;
          case "logout":
            logout(payload: payload, socket: socket, colection: expiredToken);
            break;
          default:
        }
      },
    );
  } catch (e, s) {
    print(e);
    print(s);
  } finally {
    await dataBase.close();
  }
}

void main(List<String> args) async {
  final server = await HttpServer.bind('127.0.0.1', 8080);
  print('webSocker listening on ws:/$server');

  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      final socket = await WebSocketTransformer.upgrade(request);
      final chanel = IOWebSocketChannel(socket);
      handleWebSocket(chanel);
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

// Future<Response> addNewCollection(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);

//     final newCollection = data['category'];

//     if (!data.containsKey('category')) {
//       return Response(404,
//           body: json.encode(
//             {"message": "missing some field"},
//           ));
//     }

//     if (db['category'].containsKey(newCollection)) {
//       return Response(404,
//           body: json.encode(
//             {"message": "new category already exists"},
//           ));
//     }

//     db['category'][newCollection] = {};
//     print(db['category']);
//     return Response(200,
//         body: json.encode({"message": "success to add new category"}));
//   } catch (e, s) {
//     print(e);
//     print(s);
//     return Response(500,
//         body: json.encode({"message": "internal server error"}));
//   }
// }

// Future<Response> addItemToInventory(Request req) async {
//   try {
//     final request = await req.readAsString();
//     final data = json.decode(request);
//     if (!data.containsKey("category") ||
//         !data.containsKey("name") ||
//         !data.containsKey("label")) {
//       return Response(400,
//           body: json.encode({"message": "missing some field"}));
//     }
//     final nameCategory = data['category'];
//     final nameItem = data['name'];
//     final label = data['label'];
//     final image = data['image'];

//     if (!db['category'].containsKey(nameCategory)) {
//       print("the category is not exists ");
//       return Response(404,
//           body: json.encode({"message": "category is not found"}));
//     }

//     final List lastIndex =
//         db['category'][nameCategory].keys.map((key) => int.parse(key)).toList();
//     // Menghitung key terakhir jika sudah ada data
//     int lastKey =
//         lastIndex.isEmpty ? 0 : lastIndex.reduce((a, b) => a > b ? a : b);

//     // Menentukan key baru yang increment
//     String newKey = "${lastKey + 1}";

//     // Menambahkan item baru dengan key increment
//     db['category'][nameCategory]![newKey] = {
//       'name': nameItem,
//       'Label': label,
//       "status": "available",
//       'image': image ?? "-",
//     };
//     print(db['category']);
//     return Response(200,
//         body: json.encode({"message": "success to add item to inventory"}));
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
