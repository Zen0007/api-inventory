import 'dart:convert';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  late IOWebSocketChannel channels;

  setUp(
    () {
      channels = IOWebSocketChannel.connect('ws://localhost:8080/ws');
    },
  );

  test(
    "test endpoint",
    () async {
      channels.sink.add(
        jsonEncode(
          {
            "endpoint": "newCollection",
            "data": {"category": "pc"}
          },
        ),
      );

      final res = await channels.stream.first;
      print(res);
    },
  );
}
