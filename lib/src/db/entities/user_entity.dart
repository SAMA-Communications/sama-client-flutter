import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import 'avatar_entity.dart';

@Entity()
// ignore: must_be_immutable
class UserEntity extends Equatable {
  @Id()
  int? id;
  @Unique(onConflict: ConflictStrategy.replace)
  final String? uid;
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

  UserEntity({
    this.id,
    this.uid,
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

  final avatar = ToOne<AvatarEntity>();

  UserEntity copyWith({
    String? uid,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? recentActivity,
    String? login,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    AvatarEntity? avatar,
  }) {
    return UserEntity(
        uid: uid ?? this.uid,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        recentActivity: recentActivity ?? this.recentActivity,
        login: login ?? this.login,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        email: email ?? this.email)
      ..avatar.target = avatar ?? this.avatar.target;
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
