import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../objectbox.g.dart';
import 'models/conversation_model.dart';
import 'models/user_model.dart';

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

  Future<List<ConversationModel>> getAllConversationsLocal() async {
    final db = await store;
    final query = db!
        .box<ConversationModel>()
        .query()
        .order(ConversationModel_.updatedAt, flags: Order.descending)
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<ConversationModel?> getConversationLocal(String cid) async {
    final db = await store;
    final query = db!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(cid))
        .build();
    final results = await query.findAsync();
    query.close();
    return results[0];
  }

  Future<List<ConversationModel>> getConversationsLocal(
      List<String> ids) async {
    final db = await store;

    final query = db!
        .box<ConversationModel>()
        .query(ConversationModel_.id.oneOf(ids))
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<bool> saveConversationsLocal(List<ConversationModel> items) async {
    final db = await store;

// https://docs.objectbox.io/entity-annotations#unique-constraints need to be updated manually
    final query = db!
        .box<ConversationModel>()
        .query(ConversationModel_.id
            .oneOf(items.map((element) => element.id).toList()))
        .build();

    final chatsInDb = await query.findAsync();
    query.close();

    var chatsInDbMap = {for (var v in chatsInDb) v.id: v};
    for (var chat in items) {
      final chatInDb = chatsInDbMap[chat.id];
      if (chatInDb != null) {
        chat.bid = chatInDb.bid;
        chat.opponent?.bid = chatInDb.opponent?.bid;
        chat.owner?.bid = chatInDb.owner?.bid;
        if (chatInDb.avatar?.fileId == chat.avatar?.fileId) {
          chat.avatar?.bid = chatInDb.avatar?.bid;
        }
        if (chatInDb.lastMessage?.id == chat.lastMessage?.id) {
          chat.lastMessage?.bid = chatInDb.lastMessage?.bid;
        }
      }
    }

    await db.box<ConversationModel>().putManyAsync(items, mode: PutMode.put);
    return true;
  }

  Future<bool> saveConversationLocal(ConversationModel item) async {
    final db = await store;
    await db!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> updateConversationLocal(ConversationModel item) async {
    final db = await store;
    await db!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> removeConversationLocal(String id) async {
    final db = await store;
    final query = db!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(id))
        .build();
    await query.removeAsync();
    query.close();
    // final results = await query.findAsync();
    // query.close();
    // await db.box<ConversationModel>().removeAsync(results[0].bid!);
    return true;
  }

  /// ////////////////////////
  /// User Store Functions ///
  /// ////////////////////////

  Future<UserModel?> getUserLocal(String id) async {
    final db = await store;
    final query = db!.box<UserModel>().query(UserModel_.id.equals(id)).build();
    final results = await query.findAsync();
    query.close();
    return results[0];
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    final db = await store;

    final query = db!
        .box<UserModel>()
        .query(
            UserModel_.id.oneOf(items.map((element) => element.id!).toList()))
        .build();
    var usersInDb = await query.findAsync();
    query.close();

    var usersMap = {for (var v in usersInDb) v.id!: v};
    for (var user in items) {
      user.bid = usersMap[user.id]?.bid;
    }

    return await db
        .box<UserModel>()
        .putAndGetManyAsync(items, mode: PutMode.put);
  }

  Future<List<UserModel>> getUsersModelLocal(List<String> ids) async {
    final db = await store;

    final query = db!.box<UserModel>().query(UserModel_.id.oneOf(ids)).build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  /// ///////////////////////////
  /// Message Store Functions ///
  /// ///////////////////////////
}
