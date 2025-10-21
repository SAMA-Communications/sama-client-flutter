import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


const int dbVersion = 1;
const String dbName = 'sama_db.db';

class SamaDB {
  static final SamaDB instance = SamaDB._internal();

  static Database? _database;

  SamaDB._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var path = await getDBPath();

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDatabase,
    );
  }

  Future<List<void>> _createDatabase(Database db, int version) async {
    return await Future.wait([
      // createUsersTable(db, version),
    ]);
  }

  Future<String> getDBPath() async {
    final databasePath = await getDatabasesPath();
    return join(databasePath, dbName);
  }

  Future<void> deleteDB() {
    return getDBPath().then((path) {
      return deleteDatabase(path);
    });
  }
}
