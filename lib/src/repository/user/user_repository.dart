import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../api/api.dart';
import '../../api/api.dart' as api;
import '../../db/local/user_local_datasource.dart';
import '../../db/models/models.dart';
import '../../shared/secure_storage.dart';
import '../../shared/utils/media_utils.dart';

class UserRepository {
  final UserLocalDatasource localDatasource;

  UserRepository({required this.localDatasource}) {
    initListeners();
  }

  StreamSubscription<Map<String, dynamic>>? _lastActivitySubscription;

  final StreamController<Map<String, dynamic>> _lastActivityController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get lastActivityStream =>
      _lastActivityController.stream;

  void initListeners() {
    if (_lastActivitySubscription != null) return;

    _lastActivitySubscription = api
        .UsersManager.instance.lastActivityControllerStream
        .listen((data) async {
      _lastActivityController.add(data);
    });
  }

  Future<String?> getCurrentUserId() async {
    return (await SecureStorage.instance.getCurrentUser())?.id;
  }

  Future<UserModel?> getCurrentUser() async {
    return localDatasource.getUserLocal((await getCurrentUserId())!);
  }

  Future<UserModel?> updateUserLocal(UserModel user) async {
    return localDatasource.updateUserLocal(user);
  }

  Future<UserModel> updateCurrentUser(
      {String? currentPsw,
      String? newPassword,
      String? firstName,
      String? lastName,
      String? email,
      String? phone,
      Avatar? avatar}) async {
    var user = await api.userEdit(
        currentPassword: currentPsw,
        newPassword: newPassword,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        avatar: avatar);

    if (avatar != null) {
      final filesUrls = await api.getFilesUrls({avatar.fileId!});
      avatar = avatar.copyWith(imageUrl: filesUrls[avatar.fileId!]);
      user = user.copyWith(avatar: avatar);
    }
    var result = user.toUserModel();
    result = await localDatasource.updateUserLocal(result);
    return result;
  }

  Future<UserModel> updateAvatar(File avatarUrl) async {
    var compressedFile =
        await compressImageFile(avatarUrl, const Size(640, 480));
    final blur = await getImageHashInIsolate(compressedFile);
    final id = await api.uploadAvatarFile(compressedFile);
    final name = basename(compressedFile.path);
    Avatar avatar = Avatar(fileId: id, fileName: name, fileBlurHash: blur);

    return await updateCurrentUser(avatar: avatar);
  }

  // TODO RP finish later
  Future<Map<String, UserModel>> getUsersByIds(List<String> ids) async {
    Map<String, UserModel> participants =
        await localDatasource.getUsersModelByIds(ids);
    Set<String> idsNone = ids.where((key) => participants[key] == null).toSet();
    if (idsNone.isNotEmpty) {
      await api.getUsersByIds(idsNone).then((users) async {
        var usersLocal = await localDatasource
            .saveUsersLocal(users.map((user) => user.toUserModel()).toList());
        participants
            .addEntries(usersLocal.map((user) => MapEntry(user.id!, user)));
      });
    }
    return participants;
  }

  Future<List<UserModel>> getUsersByCids(List<String> cids) async {
    return (await api.fetchParticipants(cids))
        .$2
        .map((element) => element.toUserModel())
        .toList();
  }

  Future<UserModel?> getUserById(String id) async {
    var user = await localDatasource.getUserLocal(id);
    if (user == null) {
      user = (await api.getUsersByIds({id})).firstOrNull?.toUserModel();
      if (user != null) {
        user = (await localDatasource.saveUsersLocal([user])).first;
      }
    }
    return user;
  }

  Future<List<UserModel>> updateUsers(List<UserModel> items) async {
    return localDatasource.updateUsersLocal(items);
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    return localDatasource.saveUsersLocal(items);
  }

  Future<int> subscribeUserLastActivity(String id) {
    return api.subscribeUserLastActivity(id);
  }

  Future<bool> unsubscribeUserLastActivity() {
    return api.unsubscribeUserLastActivity();
  }

  void dispose() {
    _lastActivitySubscription?.cancel();
    api.UsersManager.instance.destroy();
  }
}
