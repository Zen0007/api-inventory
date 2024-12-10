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
    final String timeBorrow = payload['time'];

    // type another string
    final item = payload['item'];
    final String imageSelfie = payload['imageSelfie'];
    final String? imageNisn = payload['imageNisn'];

    if (nameUser.isEmpty ||
        classUser.isEmpty ||
        nisnUser.isEmpty ||
        nameTeacher.isEmpty ||
        timeBorrow.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "missing some field",
        },
      ));
    }

    if (imageSelfie.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          warning: "image is empety",
        },
      ));
    }
    final hexSelfie = await saveImage(imageSelfie, dataBase);

    final sendData = await collection.insertOne({
      nameUser: {
        "name": nameUser,
        "status": "borrow",
        "class": classUser,
        "nisn": nisnUser,
        "nameTeacher": nameTeacher,
        "imageSelfie": hexSelfie,
        "imageNisn": imageNisn ?? "empety",
        "timeBorrow": timeBorrow,
        "item": item,
      }
    });

    if (sendData.isSuccess) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
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
