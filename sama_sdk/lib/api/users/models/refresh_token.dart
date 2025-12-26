import 'package:equatable/equatable.dart';

class RefreshToken extends Equatable {
  final String? token;

  const RefreshToken({this.token});

  RefreshToken.fromJson(Map<String, dynamic> json)
    : token = json['refresh_token'];

  Map<String, dynamic> toJson() => {'refresh_token': token};

  @override
  List<Object?> get props => [token];

  RefreshToken copyWith({String? token}) {
    return RefreshToken(token: token ?? this.token);
  }

  static const empty = RefreshToken();
}
