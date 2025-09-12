import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

Future<int> _findAvailablePort() async {
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
  print(server.port);
  final port = server.port;
  await server.close();
  return port;
}

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
