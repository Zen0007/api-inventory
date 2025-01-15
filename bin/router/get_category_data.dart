import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String endpoint = 'endpoint';
const String warning = 'warning';
const String valueEdnpoint = "GETDATACATEGORYAVAILEBLE";

Future<void> getDataCategoryAvailebleOnce({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final data = await collection.find().toList();
    if (data.isEmpty) {
      socket.sink.add(json.encode(
        {
          endpoint: valueEdnpoint,
          "message": [],
        },
      ));
      return;
    }

    // Filter the data using a for loop
    List<Map<String, dynamic>> filteredData = [];

    for (var item in data) {
      Map<String, dynamic> filteredItem = {};

      item.forEach((key, value) {
        if (key == '_id') {
          filteredItem[key] = value;
        } else if (value is Map) {
          Map<String, dynamic> filteredSubItem = {};
          value.forEach((subKey, subValue) {
            if (subValue['status'] == 'available') {
              filteredSubItem[subKey] = subValue;
            }
          });
          if (filteredSubItem.isNotEmpty) {
            filteredItem[key] = filteredSubItem;
          }
        }
      });

      if (filteredItem.length > 1) {
        filteredData.add(filteredItem);
      }
    }

    socket.sink.add(json.encode(
      {
        endpoint: valueEdnpoint,
        "message": filteredData,
      },
    ));
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> getDataCategoryAvaileble({
  required WebSocketChannel socket,
  required DbCollection collection,
}) async {
  try {
    final data = await collection.find().toList();
    final List<Map<String, Object>> pipeline = [];
    final watch = collection.watch(pipeline);

    // Filter the data using a for loop
    List<Map<String, dynamic>> filteredData = [];

    for (var item in data) {
      Map<String, dynamic> filteredItem = {};

      item.forEach((key, value) {
        if (key == '_id') {
          filteredItem[key] = value;
        } else if (value is Map) {
          Map<String, dynamic> filteredSubItem = {};
          value.forEach((subKey, subValue) {
            if (subValue['status'] == 'available') {
              filteredSubItem[subKey] = subValue;
            }
          });
          if (filteredSubItem.isNotEmpty) {
            filteredItem[key] = filteredSubItem;
          }
        }
      });

      if (filteredItem.length > 1) {
        filteredData.add(filteredItem);
      }
    }

    await for (var status in watch) {
      if (status.isInsert ||
          status.isUpdate ||
          status.isReplace ||
          status.isRename ||
          status.isDelete) {
        socket.sink.add(json.encode(
          {
            endpoint: valueEdnpoint,
            "message": filteredData,
          },
        ));
        return;
      } else if (data.isEmpty) {
        socket.sink.add(json.encode(
          {
            endpoint: valueEdnpoint,
            "message": [],
          },
        ));
        return;
      }
    }
  } catch (e, s) {
    print('$e get data availeble');
    print(s);
  }
}
