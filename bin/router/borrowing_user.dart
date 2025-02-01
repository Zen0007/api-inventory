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
    final List? item = payload['items'];
    final List imageSelfie = payload['imageSelfie'];
    final List? imageNisn = payload['imageNisn'];

    if (nameUser.isEmpty ||
        classUser.isEmpty ||
        nisnUser.isEmpty ||
        nameTeacher.isEmpty ||
        timeBorrow.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEndpoint,
          warning: "beberapa form kosong harap isi ",
        },
      ));
      return;
    }

    if (imageSelfie.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEndpoint,
          warning: "image kosong",
        },
      ));
      return;
    }

    if (item == null || item.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEndpoint,
          warning: "barang yang di pinjam kosong silakan isi",
        },
      ));
      return;
    }

    // Send data to Database
    final sendData = await collection.insertOne({
      nameUser: {
        "name": nameUser,
        "status": "borrow",
        "class": classUser,
        "nisn": nisnUser,
        "nameTeacher": nameTeacher,
        "imageSelfie": imageSelfie,
        "imageNisn": imageNisn ?? '[]',
        "time": timeBorrow,
        "admin": "",
        "items": item,
      }
    });

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
