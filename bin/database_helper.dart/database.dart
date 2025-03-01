import 'package:mongo_pool/mongo_pool.dart';

class DatabaseHelper {
  final pooling = MongoDbPoolService(
    MongoPoolConfiguration(
      poolSize: 5,
      uriString: 'mongodb://localhost:27017/inventory',
      leakDetectionThreshold: 10000,
      maxLifetimeMilliseconds: 180000,
      secure: false,
      tlsAllowInvalidCertificates: false,
    ),
  );

  Future<void> initialize(MongoDbPoolService service) async {
    try {
      await service.initialize();
    } on Exception catch (e, s) {
      print(e);
      print(s);
    }
  }
}
