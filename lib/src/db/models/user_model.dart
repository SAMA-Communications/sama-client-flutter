import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import 'avatar_model.dart';


@Entity()
// ignore: must_be_immutable
class UserModel extends Equatable {
  @Id()
  int? bid;
  @Unique(onConflict: ConflictStrategy.replace)
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

  AvatarModel? get avatar => avatarBind.target;
  set avatar(AvatarModel? item) => avatarBind.target = item;

  UserModel copyWith({
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
