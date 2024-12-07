import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "BORROWING";

Future<void> borrowingItem({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
    await dataBase.open();

    // type string
    final String nameUser = payload['name'];
    final String classUser = payload['class'];
    final String nisnUser = payload['nisn'];
    final String nameTeacher = payload['teacher'];

    // type another string
    final item = payload['item'];
    final imageSelfie = payload['imageSelfie'];
    final imageNisn = payload['imageNisn'];

    if (nameUser.isEmpty ||
        classUser.isEmpty ||
        nisnUser.isEmpty ||
        nameTeacher.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "missing some field",
        },
      ));
    }

    if (imageNisn == null || imageSelfie == null) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "image is empety",
        },
      ));
    }
    final hexNisn = await saveImage(imageNisn, dataBase);
    final hexSelfie = await saveImage(imageSelfie, dataBase);

    final sendData = await collection.insertOne({
      nameUser: {
        "name": nameUser,
        "status": "borrow",
        "class": classUser,
        "nisn": nisnUser,
        "nameTeacher": nameTeacher,
        "imageSelfie": hexSelfie,
        "imageNisn": hexNisn,
        "item": item,
      }
    });

    if (sendData.success) {
      socket.sink.add(json.encode(
        {
          "endpoint": "BORROWING",
          "message": "success borrow",
        },
      ));
    } else {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "failed while borrow",
        },
      ));
    }

    // if (!db['category'][collection].containsKey(indexItem)) {
    //   return Response(404,
    //       body: json.encode(
    //         {"message": 'the name index not found in colection $collection'},
    //       ));
    // }

    // final borrowItem = db['category'][collection][indexItem];

    // final Map<String, Object> borrow = {
    //   "status": "borrow",
    //   "userName": nameUser,
    //   "class": classUser,
    //   "nameTeacher": nameTeacher,
    //   "nisn": nisnUser,
    //   "imageNisn": imageNisn ?? '-',
    //   "imageSelfie": imageSelfie ?? '-',
    //   "item": {}
    // };
    // db['borrowing'][nameUser] = borrow;

    // // Add the item to the user's borrowing collection without replacing existing items
    // db['borrowing'][nameUser]['item'][collection] ??= {};
    // db['borrowing'][nameUser]['item'][collection][indexItem] = borrowItem;

    // print(db['borrowing']);
    // return Response(200, body: json.encode({"userBorrow": nameUser}));
  } catch (e, s) {
    print(e);
    print(s);
    socket.sink.add(json.encode(
      {
        "endpoint": "DELETEITEM",
        "warning": {"error": "$e", "StackTrace": "$s"},
      },
    ));
  } finally {
    await dataBase.close();
  }
}

Future<String> saveImage(String image, Db dataBase) async {
  final base64Decoder = base64Decode(image);
  final stream = Stream.fromIterable([base64Decoder]);
  final gridFS = GridFS(dataBase);
  final gridIn = gridFS.createFile(stream, 'image.jpg');
  await gridIn.save();
  return gridIn.id.toHexString();
}
