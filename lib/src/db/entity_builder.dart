import 'package:sama_client_flutter/src/db/models/attachment_model.dart';
import 'package:sama_client_flutter/src/db/models/message_model.dart';

import '../api/api.dart';
import 'models/avatar_model.dart';
import 'models/user_model.dart';

// TODO RP make extension
UserModel? buildWithUser(User? user) {
  if (user == null) return null;
  var userModel =  UserModel(
    id: user.id,
    deviceId: user.deviceId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    recentActivity: user.recentActivity,
    login: user.login,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    email: user.email,
  );
  if (user.avatar != null) {
    userModel.avatar = buildWithAvatar(user.avatar);
  }
  return userModel;
}

User? buildWithUserModel(UserModel? user) {
  if (user == null) return null;
  return User(
    id: user.id,
    deviceId: user.deviceId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    recentActivity: user.recentActivity,
    login: user.login,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    email: user.email,
  );
}

MessageModel? buildWithMessage(Message? message) {
  if (message == null) return null;
  var messageModel = MessageModel(
    id: message.id,
    from: message.from,
    cid: message.cid,
    rawStatus: message.rawStatus,
    body: message.body,
    createdAt: message.createdAt,
    t: message.t,
  );
  if (message.attachments != null) {
    messageModel.attachments.addAll(message.attachments!
        .map((attachment) => attachment.toAttachmentModel()));
  }

  return messageModel;
}

AvatarModel? buildWithAvatar(Avatar? avatar) {
  if (avatar == null) return null;
  return AvatarModel(
    fileId: avatar.fileId,
    fileName: avatar.fileName,
    fileBlurHash: avatar.fileBlurHash,
    imageUrl: avatar.imageUrl,
  );
}
