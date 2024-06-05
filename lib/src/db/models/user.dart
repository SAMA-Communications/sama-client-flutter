import 'package:sqflite/sqflite.dart';

class UserFields {
  static const String tableName = 'users';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String userId = 'user_id';
  static const String login = 'login';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';

  static const List<String> values = [
    id,
    userId,
    login,
    firstName,
    lastName,
  ];
}

class UserModel {
  final int id;
  final String userId;
  final String login;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.userId,
    required this.login,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, Object?> json) => UserModel(
        id: json[UserFields.id] as int,
        userId: json[UserFields.userId] as String,
        login: json[UserFields.login] as String,
        firstName: json[UserFields.firstName] as String?,
        lastName: json[UserFields.lastName] as String?,
      );

  Map<String, Object?> toJson() => {
        UserFields.id: id,
        UserFields.userId: userId,
        UserFields.login: login,
        UserFields.firstName: firstName,
        UserFields.lastName: lastName,
      };

  UserModel copy({
    int? id,
    String? userId,
    String? login,
    String? firstName,
    String? lastName,
  }) =>
      UserModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        login: login ?? this.login,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
      );
}

Future<void> createUsersTable(Database db, int version) {
  return db.execute('''
        CREATE TABLE ${UserFields.tableName} (
          ${UserFields.id} ${UserFields.idType},
          ${UserFields.userId} ${UserFields.textType},
          ${UserFields.login} ${UserFields.textType},
          ${UserFields.firstName} ${UserFields.textType},
          ${UserFields.lastName} ${UserFields.textType},
        )
      ''');
}

Future<UserModel> addUser(Database db, UserModel note) async {
  return db.insert(UserFields.tableName, note.toJson()).then((id) {
    return note.copy(id: id);
  });
}

Future<UserModel?> getUserById(Database db, String userId) async {
  return db.query(
    UserFields.tableName,
    columns: UserFields.values,
    where: '${UserFields.userId} = ?',
    whereArgs: [userId],
  ).then((maps) {
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    } else {
      return null;
    }
  });
}

Future<UserModel> updateUser(Database db, UserModel user) async {
  return db.update(
    UserFields.tableName,
    user.toJson(),
    where: '${UserFields.userId} = ?',
    whereArgs: [user.userId],
  ).then((id) {
    return user.copy(id: id);
  });
}

Future<int> deleteUser(Database db, String userId) async {
  return db.delete(
    UserFields.tableName,
    where: '${UserFields.userId} = ?',
    whereArgs: [userId],
  );
}
