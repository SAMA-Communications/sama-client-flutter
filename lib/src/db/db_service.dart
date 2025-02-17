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

  static Store? store;

  void init() async {
    store ??= await _create();
  }

  Future<Store> _create() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, dbName);
    final store = await openStore(directory: dbPath);
    return store;
  }

  void drop() async {
    try {
      close();
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
      store?.close();
      store = null;
    } catch (e) {
      return;
    }
  }

  /// ////////////////////////////////
  /// Conversation Store Functions ///
  /// ////////////////////////////////

  Future<List<ConversationModel>> getAllConversationsLocal() async {
    final query = store!
        .box<ConversationModel>()
        .query()
        .order(ConversationModel_.updatedAt, flags: Order.descending)
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<ConversationModel?> getConversationLocal(String cid) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(cid))
        .build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<List<ConversationModel>> getConversationsLocal(
      List<String> ids) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.oneOf(ids))
        .build();
    final results = query.findAsync();
    query.close();
    return results;
  }

  Future<bool> saveConversationsLocal(List<ConversationModel> items) async {
// https://docs.objectbox.io/entity-annotations#unique-constraints need to be updated manually
    final query = store!
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

    await store!
        .box<ConversationModel>()
        .putManyAsync(items, mode: PutMode.put);
    return true;
  }

  Future<bool> saveConversationLocal(ConversationModel item) async {
    await store!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> updateConversationLocal(ConversationModel item) async {
    await store!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> removeConversationLocal(String id) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(id))
        .build();
    var result = await query.removeAsync();
    query.close();
    // final item = await query.findFirstAsync();
    // query.close();
    // await store!.box<ConversationModel>().removeAsync(item!.bid!);
    return true;
  }

  /// ////////////////////////
  /// User Store Functions ///
  /// ////////////////////////

  Future<UserModel?> getUserLocal(String id) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.equals(id)).build();
    final user = query.findFirst();
    query.close();
    return user;
  }

  Future<UserModel> saveUserLocal(UserModel item) async {
    return store!.box<UserModel>().putAndGetAsync(item, mode: PutMode.put);
  }

  Future<UserModel> updateUserLocal(UserModel item) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.equals(item.id!)).build();
    final userInDb = query.findFirst();
    query.close();

    item.bid = userInDb?.bid;
    item.avatar?.bid = userInDb?.avatar?.bid;
    return store!.box<UserModel>().putAndGetAsync(item, mode: PutMode.put);
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    final query = store!
        .box<UserModel>()
        .query(
            UserModel_.id.oneOf(items.map((element) => element.id!).toList()))
        .build();
    var usersInDb = await query.findAsync();
    query.close();

    var usersMap = {for (var v in usersInDb) v.id!: v};
    for (var user in items) {
      user.bid = usersMap[user.id]?.bid;
      user.avatar?.bid = usersMap[user.id]?.avatar?.bid;
    }

    return store!.box<UserModel>().putAndGetManyAsync(items, mode: PutMode.put);
  }

  Future<List<UserModel>> getUsersModelLocal(List<String> ids) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.oneOf(ids)).build();
    final results = query.findAsync();
    query.close();
    return results;
  }

  /// ///////////////////////////
  /// Message Store Functions ///
  /// ///////////////////////////
}
