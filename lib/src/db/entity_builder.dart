import '../api/api.dart';
import 'entities/avatar_entity.dart';
import 'entities/message_entity.dart';
import 'entities/user_entity.dart';

UserEntity? buildWithUser(User? user) {
  if (user == null) return null;
  return UserEntity(
    uid: user.id,
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

MessageEntity? buildWithMessage(Message? message) {
  if (message == null) return null;
  return MessageEntity(
    uid: message.id,
    from: message.from,
    cid: message.cid,
    rawStatus: message.rawStatus,
    body: message.body,
    createdAt: message.createdAt,
    t: message.t,
  );
}

AvatarEntity? buildWithAvatar(Avatar? avatar) {
  if (avatar == null) return null;
  return AvatarEntity(
    fileId: avatar.fileId,
    fileName: avatar.fileName,
    fileBlurHash: avatar.fileBlurHash,
    imageUrl: avatar.imageUrl,
  );
}
