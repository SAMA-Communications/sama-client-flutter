import 'package:equatable/equatable.dart';

class AccessToken extends Equatable {
  final String? token;
  final int? expiredAt; //expired_at

  const AccessToken({
    this.token,
    this.expiredAt,
  });

  AccessToken.fromJson(Map<String, dynamic> json)
      : token = json['access_token'],
        expiredAt = json['expired_at'];

  Map<String, dynamic> toJson() => {
        'token': token,
        'expired_at': expiredAt,
      };

  @override
  List<Object?> get props => [
        token,
        expiredAt,
      ];

  AccessToken copyWith({
    String? token,
    int? expiredAt,
  }) {
    return AccessToken(
      token: token ?? this.token,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  static const empty = AccessToken();
}
