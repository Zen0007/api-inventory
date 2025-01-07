import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEndpoint = "BORROWING";

Future<void> borrowingItem({
  required WebSocketChannel socket,
  required Db dataBase,
  required DbCollection collection,
  required dynamic payload,
}) async {
  try {
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
          endpoint: valueEndpoint,
          warning: "missing some field",
        },
      ));
      return;
    }

    if (imageSelfie.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEndpoint,
          warning: "image is empety",
        },
      ));
      return;
    }

    // process data image to hexString
    final selfieJson = json.encode(imageSelfie);
    final nisnJson = json.encode(imageNisn);

    final dataUserBorrow = {
      nameUser: {
        "name": nameUser,
        "status": "borrow",
        "class": classUser,
        "nisn": nisnUser,
        "nameTeacher": nameTeacher,
        "imageSelfie": selfieJson,
        "imageNisn": nisnJson,
        "time": timeBorrow,
        "admin": "",
        "items": item,
      }
    };

    // Send data to Database
    final sendData = await collection.insertOne(dataUserBorrow);

    if (sendData.isSuccess) {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEndpoint,
            "message": "success",
          },
        ),
      );
      return;
    } else {
      socket.sink.add(
        json.encode(
          {
            endpoint: valueEndpoint,
            warning: "failed while borrow",
          },
        ),
      );
    }
  } catch (e, s) {
    print(e);
    print(s);
    socket.sink.add(json.encode(
      {
        endpoint: valueEndpoint,
        "warning": {"error": "$e", "StackTrace": "$s"},
      },
    ));
  }
}

// convert string to grid mongodb and return hexString
Future<String> saveImage(String? image, Db dataBase) async {
  if (image == null) {
    return "empty";
  }
  final base64Decoder = base64Decode(image);
  final stream = Stream.fromIterable([base64Decoder]);
  final gridFS = GridFS(dataBase);
  final gridIn = gridFS.createFile(stream, 'image.jpg');
  await gridIn.save();
  return gridIn.id.toHexString();
}
