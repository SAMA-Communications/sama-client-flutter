import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id; //_id
  final String? deviceId;
  final DateTime? createdAt; //created_at
  final DateTime? updatedAt; //updated_at
  final int? recentActivity; //recent_activity
  final String? login;
  final String? password;
  final String? firstName; //first_name
  final String? lastName; //last_name
  final String? phone;
  final String? email;

  const User({
    this.id,
    this.deviceId,
    this.createdAt,
    this.updatedAt,
    this.recentActivity,
    this.login,
    this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        deviceId = json['deviceId'],
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        recentActivity =
            int.tryParse(json['recent_activity']?.toString() ?? ''),
        login = json['login'],
        password = json['password'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        phone = json['phone'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        '_id': id,
        'deviceId': deviceId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'recent_activity': recentActivity,
        'login': login,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
      };

  @override
  List<Object?> get props => [
        id,
        login,
        password,
        firstName,
        lastName,
        phone,
        email,
      ];

  User copyWith({
    String? id,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? recentActivity,
    String? login,
    String? password,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recentActivity: recentActivity ?? this.recentActivity,
      login: login ?? this.login,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  static const empty = User();
}
