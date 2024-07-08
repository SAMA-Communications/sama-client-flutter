import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id; //_id
  final String? deviceId;
  final DateTime? createdAt; //created_at
  final DateTime? updatedAt; //updated_at
  final int? recentActivity; //recent_activity
  final String? firstName; //first_name
  final String? lastName; //last_name
  final String? password;
  final String? login;
  final String? email;
  final String? phone;

  const User({
    this.id,
    this.deviceId,
    this.firstName,
    this.lastName,
    this.password,
    this.login,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.recentActivity,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        deviceId = json['deviceId'],
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        recentActivity =
            int.tryParse(json['recent_activity']?.toString() ?? ''),
        firstName = json['first_name'],
        lastName = json['last_name'],
        password = json['password'],
        login = json['login'],
        email = json['email'],
        phone = json['last_name'];

  Map<String, dynamic> toJson() => {
        '_id': id,
        'deviceId': deviceId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'recent_activity': recentActivity,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'login': login,
        'email': email,
        'phone': phone,
      };

  @override
  List<Object?> get props => [
        id,
        login,
        email,
      ];

  static const empty = User();
}
