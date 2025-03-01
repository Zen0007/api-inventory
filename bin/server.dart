import 'dart:io';
import 'package:mongo_pool/mongo_pool.dart';
import 'package:web_socket_channel/io.dart';
import "handler_client.dart";
import 'dart:developer' as dev;

void main(List<String> args) async {
  try {
    final pooling = MongoDbPoolService(
      MongoPoolConfiguration(
        poolSize: 100,
        uriString: 'mongodb://localhost:27017/inventory',
        leakDetectionThreshold: 120000,
        maxLifetimeMilliseconds: 180000,
        secure: false,
        tlsAllowInvalidCertificates: false,
      ),
    );
    await initializePooling(pooling);

    final int port = 8080;
    final server = await HttpServer.bind("127.0.0.1", port);
    print('webSocker listening on ws:/${server.port}');
    print("port ${server.address}");
    await for (HttpRequest request in server) {
      try {
        if (request.uri.path == '/ws') {
          final socket = await WebSocketTransformer.upgrade(request);
          final chanel = IOWebSocketChannel(socket);

          handleWebSocket(chanel, pooling);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..close();
        }
      } catch (e, s) {
        print(e);
        print(s);
      } finally {
        dev.log("finnaly was complate");
        print("finnaly was complate");
      }
    }

    print("done");
  } catch (e, s) {
    print(e);
    print(s);
  }
}

Future<void> initializePooling(MongoDbPoolService service) async {
  try {
    await service.initialize();
  } on Exception catch (e, s) {
    print(e);
    print(s);
  }
}
