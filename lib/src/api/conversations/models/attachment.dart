import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String? fileId; //file_id
  final String? fileName; //file_name
  final String? fileBlurHash; //file_blur_hash
  final String? fileUrl; //file_url
  final String? fileContentType; //file_content_type
  final int? fileHeight; //file_height
  final int? fileWidth; //file_width

  const Attachment({
    this.fileId,
    this.fileName,
    this.fileBlurHash,
    this.fileUrl,
    this.fileContentType,
    this.fileHeight,
    this.fileWidth,
  });

  Attachment.fromJson(Map<String, dynamic> json)
      : fileId = json['file_id'],
        fileName = json['file_name'],
        fileBlurHash = json['file_blur_hash'],
        fileUrl = json['file_url'],
        fileContentType = json['file_content_type'],
        fileHeight = json['file_height'],
        fileWidth = json['file_width'];

  Map<String, dynamic> toJson() => {
        'file_id': fileId,
        'file_name': fileName,
        'file_blur_hash': fileBlurHash,
        if (fileUrl != null) 'file_url': fileUrl,
        if (fileContentType != null) 'file_content_type': fileContentType,
        if (fileHeight != null) 'file_height': fileHeight,
        if (fileWidth != null) 'file_width': fileWidth,
      };

  @override
  List<Object?> get props => [
        fileId,
        fileName,
        fileBlurHash,
        fileUrl,
        fileContentType,
        fileHeight,
        fileWidth
      ];

  static const empty = Attachment();
}
