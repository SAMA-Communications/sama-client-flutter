import 'package:equatable/equatable.dart';

class PushMessageData extends Equatable {
  final String? cid;
  final String? title;
  final String? body;
  final String? firstAttachmentUrl;
  final String? firstAttachmentFileId;

  const PushMessageData({
    this.cid,
    this.title,
    this.body,
    this.firstAttachmentUrl,
    this.firstAttachmentFileId,
  });

  PushMessageData.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        title = json['title'],
        body = json['body'],
        firstAttachmentUrl = json['firstAttachmentUrl'],
        firstAttachmentFileId = json['firstAttachmentFileId'];

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'title': title,
        'body': body,
      };

  @override
  List<Object?> get props => [cid, title, body, firstAttachmentUrl];

  static const empty = PushMessageData();
}
