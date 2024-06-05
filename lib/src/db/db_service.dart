import 'package:sama_client_flutter/src/db/sama_db.dart';
import 'package:sqflite/sqflite.dart';

import 'models/user.dart' as users;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  Future<Database> get db => SamaDB.instance.database;

  DatabaseService._internal();

  // Users part
  Future<users.UserModel> addUser(users.UserModel user) async {
    return db.then((db) {
      return users.addUser(db, user);
    });
  }

  Future<users.UserModel?> getUserById(String userId) async {
    return db.then((db) {
      return users.getUserById(db, userId);
    });
  }

  Future<users.UserModel> updateUser(users.UserModel user) async {
    return db.then((db) {
      return users.updateUser(db, user);
    });
  }

  Future<int> deleteUser(String userId) async {
    return db.then((db) {
      return users.deleteUser(db, userId);
    });
  }
}
