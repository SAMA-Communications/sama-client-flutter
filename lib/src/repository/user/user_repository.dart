import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sama_client_flutter/src/db/entity_builder.dart';

import '../../api/api.dart';
import '../../api/api.dart' as api;
import '../../db/models/user_model.dart';
import '../../repository/user/user_data_source.dart';
import '../../shared/secure_storage.dart';
import '../../shared/utils/media_utils.dart';

class UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepository({required this.localDataSource});

  Future<User?> getLocalUser() async {
    return SecureStorage.instance.getLocalUser();
  }

  Future<User> updateLocalUser(
      {String? currentPsw,
      String? newPassword,
      String? firstName,
      String? lastName,
      String? email,
      String? phone,
      Avatar? avatar}) async {
    User result = await api.userEdit(
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
      result = result.copyWith(avatar: avatar);
    }

    SecureStorage.instance.saveLocalUserIfNeed(result);
    return result;
  }

  Future<User> updateAvatar(File avatarUrl) async {
    var compressedFile =
        await compressImageFile(avatarUrl, const Size(640, 480));
    final blur = await getImageHashInIsolate(compressedFile);
    final id = await api.uploadAvatarFile(compressedFile);
    final name = basename(compressedFile.path);
    Avatar avatar = Avatar(fileId: id, fileName: name, fileBlurHash: blur);

    return await updateLocalUser(avatar: avatar);
  }

  // TODO RP finish later
  Future<Map<String, UserModel?>> getUsersByIds(List<String> ids) async {
    Map<String, UserModel?> participants =
        await localDataSource.getUsersModelByIds(ids);
    Set<String> idsNone =
        participants.keys.where((key) => participants[key] == null).toSet();

    if (idsNone.isNotEmpty) {
      await api.getUsersByIds(idsNone).then((users) async {
        var usersLocal = await localDataSource
            .saveUsersLocal(users.map((user) => buildWithUser(user)!).toList());
        participants
            .addEntries(usersLocal.map((user) => MapEntry(user.id!, user)));
      });
    }
    return participants;
  }

  Future<Map<String, User?>> getStoredUsersByIds(List<String> ids) async {
    return localDataSource.getUsersByIds(ids);
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    return localDataSource.saveUsersLocal(items);
  }
}
