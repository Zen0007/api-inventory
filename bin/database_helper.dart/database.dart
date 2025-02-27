import 'package:mongo_dart/mongo_dart.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Db? _db;

  // Factory constructor to return the same instance
  factory DatabaseHelper() {
    return _instance;
  }

  // Private internal constructor
  DatabaseHelper._internal();

  Future<Db> get db async {
    if (_db == null) {
      _db = Db('mongodb://localhost:27017/inventory');
      await _db!.open();
    }

    if (_db!.state != State.closed) {
      await _db!.open();
    }
    print(_db!.isConnected);
    return _db!;
  }

  Future<void> close() async {
    if (_db != null && _db!.state == State.open) {
      await _db!.close();
    }
  }
}
