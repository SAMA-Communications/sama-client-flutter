import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../objectbox.g.dart';
import 'entities/conversation_entity.dart';
import 'entities/user_entity.dart';
import 'models/user.dart' as users;

const dbName = 'SamaObjectBox';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static Store? _store;

  Future<Store?> get store async {
    _store ??= await _create();
    return _store;
  }

  Future<Store> _create() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, dbName);
    final store = await openStore(directory: dbPath);
    return store;
  }

  void drop() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      Directory('${dir.path}/$dbName').deleteSync(recursive: true);
      print(
          'drop $dbName exists ${await Directory('${dir.path}/$dbName').exists()}');
    } catch (e) {
      print('drop e ${e}');
      return;
    }
  }

  void close() async {
    try {
      _store?.close();
    } catch (e) {
      return;
    }
  }

  /// ////////////////////////////////
  /// Conversation Store Functions ///
  /// ////////////////////////////////

  Future<List<ConversationEntity>> getAllConversationsLocal() async {
    final db = await store;
    final query = db!
        .box<ConversationEntity>()
        .query()
        .order(ConversationEntity_.updatedAt)
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<ConversationEntity> getConversationLocal(String cid) async {
    final db = await store;
    final query = db!
        .box<ConversationEntity>()
        .query(ConversationEntity_.uid.equals(cid))
        .build();
    final results = await query.findAsync();
    query.close();
    return results[0];
  }

  Future<bool> saveConversationsLocal(List<ConversationEntity> items) async {
    final db = await store;
    await db!.box<ConversationEntity>().putManyAsync(items, mode: PutMode.put);
    return true;
  }

  Future<bool> saveConversationLocal(ConversationEntity item) async {
    final db = await store;
    await db!.box<ConversationEntity>().putAsync(item, mode: PutMode.put);
    return true;
  }

  /// ///////////////////////////
  /// Message Store Functions ///
  /// ///////////////////////////

  /// ////////////////////////
  /// User Store Functions ///
  /// ////////////////////////

  Future<UserEntity> getUserLocal(String uid) async {
    final db = await store;
    final query =
        db!.box<UserEntity>().query(UserEntity_.uid.equals(uid)).build();
    final results = await query.findAsync();
    query.close();
    return results[0];
  }
}
