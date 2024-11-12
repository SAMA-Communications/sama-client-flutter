import 'package:equatable/equatable.dart';

class PushSubscription extends Equatable {
  final String? id; //_id
  final DateTime? createdAt; //created_at
  final DateTime? updatedAt; //updated_at
  final String? platform; //platform
  final String? deviceId; //device_udid
  final String? userId; //user_id

  const PushSubscription({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.platform,
    this.deviceId,
    this.userId,
  });

  PushSubscription.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        platform = json['platform'],
        deviceId = json['device_udid'],
        userId = json['user_id'];

  Map<String, dynamic> toJson() => {
        '_id': id,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'platform': platform,
        'device_udid': deviceId,
        'user_id': userId,
      };

  @override
  List<Object?> get props => [
        id,
      ];

  static const empty = PushSubscription();
}
