import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
//import 'package:mongo_dart/mongo_dart.dart';

// final String url = 'mongodb://localhost:27017/inventory';

// final dataBase = Db(url);
// final itemColection = dataBase.collection('category');
// final authAdmin = dataBase.collection('auth');

final Map<String, dynamic> db = {
  "auth": {
    "asta": {
      "name": "asta",
      "password": "asta1234",
    },
    "yuno": {
      "name": "yuno",
      "password": "yuno1234^",
    }
  },
  'category': {
    "mikrotick": {
      "1": {
        "name": "cisco",
        "label": "no 2",
        "image": "-",
        "status": "availeble"
      }
    },
    "accesPoint": {
      "1": {
        "label": "no 123",
        "nameItem": "tp Link",
        "image": "-",
        "status": "availeble"
      },
      "2": {
        "label": "no 334",
        "nameItem": "tp Link",
        "image": "-",
        "status": "availeble"
      }
    }
  },
  "borrowing": {},
  "pending": {},
  "itemBack": {},
};

const String secretKey =
    "xr@7(@+mrO)QjA1E_5xXe1@DqC5&VhuhY@*)E)tsUTn5G)USsv^JUGa\$9hSne9RB";

// Configure routes.
final _router = Router()
  ..post("/addNewAdmin", addNewAdmin)
  ..post("/login", login)
  ..post("/verifikasi", verifikasiToken)
  ..post("/addNewCategory", addItemToInventory)
  ..post("/addNewCollection", addNewCollection)
  ..post("/borrowingItem", borrowingItem)
  ..post("/pending", waithPermitAdmin)
  ..post("/granted", granted)
  ..post("/checkUserIsBorrow", checkUserIsBorrow)
  ..post("/updateStatus", updateStatusItem)
  ..delete("/deleteItem", deleteItem)
  ..delete("/deleteUserPriod", deleteBorrowingUser);

Future<Response> addNewAdmin(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);
    if (!data.containsKey('name') || !data.containsKey('password')) {
      return Response(404,
          body: json.encode(
            {
              "message": "missing field",
            },
          ));
    }
    final nameNewAdmin = data['name'];
    final passowrd = data['password'];

    db['auth'] = {
      nameNewAdmin: {
        "name": nameNewAdmin,
        "password": passowrd,
      },
    };
    print(db['auth']);
    return Response(200,
        body: json.encode({"message": "success add new admin"}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> login(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);
    if (!data.containsKey('name') || !data.containsKey('password')) {
      return Response(404,
          body: json.encode({"message": "name admin not found "}));
    }

    final userName = data['name'];
    final password = data['password'];

    if (!db['auth'].containsKey(userName)) {
      return Response(404,
          body: json.encode({"message": "user not exists in databse"}));
    }
    if (db['auth'][userName]['name'] != userName ||
        db['auth'][userName]['password'] != password) {
      return Response(404, body: json.encode({"message": "user name invalid"}));
    }

    final payload = {
      "username": userName,
      'exp':
          DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
    };

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(secretKey));

    return Response(200,
        body: json.encode(
          {
            "token": token,
          },
        ));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> verifikasiToken(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    if (!data.containsKey('status')) {
      return Response(200, body: json.encode({"status": "NOT-VERIFIKASI"}));
    }

    final status = data['status'];
    if (status == null) {
      return Response(200, body: json.encode({"status": "NOT-VERIFIKASI"}));
    }

    JWT.verify(status, SecretKey(secretKey));
    return Response(200, body: json.encode({"status": "VERIFIKASI"}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(200, body: json.encode({"status": "NOT-VERIFIKASI"}));
  }
}

Future<Response> logout(Request req) async {
  try {
    return Response(200, body: json.encode({"message": "succes delete user "}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> deleteBorrowingUser(Request req) async {
  try {
    return Response(200,
        body: json.encode({"message": "success delete user "}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> deleteItem(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final nameCategory = data['category'];
    final item = data['item'];

    db['category'][nameCategory].remove(item);
    return Response(200,
        body: json.encode({"message": "success to delete item"}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> updateStatusItem(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final category = data['category'];
    final indexItem = data['index'];
    final newStatus = data['status'];

    db['category'][category][indexItem]['status'] = newStatus;

    print(db['category']);
    return Response(200,
        body: json.encode(
          {
            "message": "success update status",
          },
        ));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> addNewCollection(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final newCollection = data['category'];

    if (!data.containsKey('category')) {
      return Response(404,
          body: json.encode(
            {"message": "missing some field"},
          ));
    }

    if (db['category'].containsKey(newCollection)) {
      return Response(404,
          body: json.encode(
            {"message": "new category already exists"},
          ));
    }

    db['category'][newCollection] = {};
    print(db['category']);
    return Response(200,
        body: json.encode({"message": "success to add new category"}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> addItemToInventory(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);
    if (!data.containsKey("category") ||
        !data.containsKey("name") ||
        !data.containsKey("label")) {
      return Response(400,
          body: json.encode({"message": "missing some field"}));
    }
    final nameCategory = data['category'];
    final nameItem = data['name'];
    final label = data['label'];
    final image = data['image'];

    if (!db['category'].containsKey(nameCategory)) {
      print("the category is not exists ");
      return Response(404,
          body: json.encode({"message": "category is not found"}));
    }

    final List lastIndex =
        db['category'][nameCategory].keys.map((key) => int.parse(key)).toList();
    // Menghitung key terakhir jika sudah ada data
    int lastKey =
        lastIndex.isEmpty ? 0 : lastIndex.reduce((a, b) => a > b ? a : b);

    // Menentukan key baru yang increment
    String newKey = "${lastKey + 1}";

    // Menambahkan item baru dengan key increment
    db['category'][nameCategory]![newKey] = {
      'name': nameItem,
      'Label': label,
      "status": "available",
      'image': image ?? "-",
    };
    print(db['category']);
    return Response(200,
        body: json.encode({"message": "success to add item to inventory"}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> borrowingItem(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final nameUser = data['name'];
    final classUser = data['class'];
    final nisnUser = data['nisn'];
    final nameTeacher = data['teacher'];
    final indexItem = data['item'];
    final collection = data['collection'];
    final imageSelfie = data['imageSelfie'];
    final imageNisn = data['imageNisn'];
    if (!data.containsKey('name') ||
        !data.containsKey('class') ||
        !data.containsKey('nisn') ||
        !data.containsKey('teacher') ||
        !data.containsKey('imageSelfie') ||
        !data.containsKey('imageNisn')) {
      return Response(404,
          body: json.encode({"message": "missing some field"}));
    }

    if (db['borrowing'].containsKey(nameUser)) {
      return Response(404,
          body: json.encode(
            {
              "message": "still borrow item pleas return item alredy borrow",
            },
          ));
    }

    if (!db['category'][collection].containsKey(indexItem)) {
      return Response(404,
          body: json.encode(
            {"message": 'the name index not found in colection $collection'},
          ));
    }
    final borrowItem = db['category'][collection][indexItem];

    final Map<String, Object> borrow = {
      "status": "borrow",
      "userName": nameUser,
      "class": classUser,
      "nameTeacher": nameTeacher,
      "nisn": nisnUser,
      "imageNisn": imageNisn ?? '-',
      "imageSelfie": imageSelfie ?? '-',
      "item": {}
    };
    db['borrowing'][nameUser] = borrow;

    // Add the item to the user's borrowing collection without replacing existing items
    db['borrowing'][nameUser]['item'][collection] ??= {};
    db['borrowing'][nameUser]['item'][collection][indexItem] = borrowItem;
    print(db['borrowing']);
    return Response(200, body: json.encode({"userBorrow": nameUser}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500, body: json.encode({"message": "$e", "s": "$s"}));
  }
}

Future<Response> checkUserIsBorrow(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);
    final dataUser = data['name'];

    if (!db['borrowing'].containsKey(dataUser)) {
      return Response(404, body: json.encode({"user": "not"}));
    }
    final user = db['borrowing'][dataUser];
    print(db['borrowing']);
    return Response(200, body: json.encode({"user": user}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "internal server error"}));
  }
}

Future<Response> waithPermitAdmin(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final nameUser = data['nameUser'];

    final pending = db['borrowing'][nameUser];
    db['borrowing'][nameUser]['status'] = "pending";

    db['pending'][nameUser] = pending;
    db['pending'][nameUser]['status'] = 'wait permit';

    print(db['pending']);
    return Response(200, body: json.encode({"message": db['pending']}));
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500,
        body: json.encode({"message": "intenal server error"}));
  }
}

Future<Response> granted(Request req) async {
  try {
    final request = await req.readAsString();
    final data = json.decode(request);

    final adminName = data['admin'];
    final userName = data['nameUser'];
    final dateTime = data['dateTime'];

    final listItem = db['borrowing'][userName]["item"];
    final pendingData = db['pending'][userName];
    print(db['borrowing'][userName]["item"]);
    db['itemBack'][userName] = pendingData;
    db['itemBack'][userName]['verifikasi'] = adminName;
    db['itemBack'][userName]['time'] = dateTime;
    db['itemBack'][userName] = {
      "item": listItem,
    };
    print("$listItem   -----");
    db['borrowing'][userName]["item"].forEach((key, value) {
      value.forEach((itemKey, itemValue) {
        if (db['category'][key] != null) {
          db['category'][key][itemKey]['status'] = "available";
        }
      });
    });
    print(pendingData);

    return Response(
      200,
      body: json.encode(
        {
          "message": db['itemBack'][userName],
          "item": db['borrowing'][userName]['item']
        },
      ),
    );
  } catch (e, s) {
    print(e);
    print(s);
    return Response(500, body: json.encode({"message": "$e", "s": "$s"}));
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
