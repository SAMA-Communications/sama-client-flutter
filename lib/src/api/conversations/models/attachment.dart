import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String? fileId; //file_id
  final String? fileName; //file_name
  final String? fileBlurHash; //file_blur_hash

  const Attachment({
    this.fileId,
    this.fileName,
    this.fileBlurHash,
  });

  Attachment.fromJson(Map<String, dynamic> json)
      : fileId = json['file_id'],
        fileName = json['file_name'],
        fileBlurHash = json['file_blur_hash'];

  Map<String, dynamic> toJson() => {
        'file_id': fileId,
        'file_name': fileName,
        'file_blur_hash': fileBlurHash,
      };

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash];

  static const empty = Attachment();
}
