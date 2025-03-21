import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../api/users/models/models.dart';
import 'avatar_model.dart';

@Entity()
// ignore: must_be_immutable
class UserModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
  final String? id;
  final String? deviceId;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;
  @Property(type: PropertyType.date)
  final DateTime? updatedAt;
  final int? recentActivity;
  final String? login;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  UserModel({
    this.bid,
    this.id,
    this.deviceId,
    this.createdAt,
    this.updatedAt,
    this.recentActivity,
    this.login,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  final avatarBind = ToOne<AvatarModel>();

  @Transient()
  AvatarModel? get avatar => avatarBind.target;

  set avatar(AvatarModel? item) => avatarBind.target = item;

  UserModel copyWith({
    int? bid,
    String? id,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? recentActivity,
    String? login,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    AvatarModel? avatar,
  }) {
    return UserModel(
        bid: bid ?? this.bid,
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        recentActivity: recentActivity ?? this.recentActivity,
        login: login ?? this.login,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        email: email ?? this.email)
      ..avatar = avatar ?? this.avatar;
  }

  @override
  List<Object?> get props => [
        id,
        login,
        firstName,
        lastName,
        phone,
        email,
        avatar,
      ];
}

extension UserModelExtension on User {
  UserModel toUserModel() {
    var userModel = UserModel(
      id: id,
      deviceId: deviceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      recentActivity: recentActivity,
      login: login,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );
    if (avatar != null) {
      userModel.avatar = avatar!.toAvatarModel();
    }
    return userModel;
  }
}
