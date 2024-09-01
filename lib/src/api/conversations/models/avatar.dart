import 'package:equatable/equatable.dart';

class Avatar extends Equatable {
  final String? fileId; //file_id
  final String? fileName; //file_name
  final String? fileBlurHash; //file_blur_hash
  final String? imageUrl; //image_url

  const Avatar({
    this.fileId,
    this.fileName,
    this.fileBlurHash,
    this.imageUrl,
  });

  Avatar.fromJson(Map<String, dynamic> json)
      : fileId = json['image_object']?['file_id'],
        fileName = json['image_object']?['file_name'],
        fileBlurHash = json['image_object']?['file_blur_hash'],
        imageUrl = json['image_url'];

  Map<String, dynamic> toImageObjectJson() => {
        'file_id': fileId,
        'file_name': fileName,
        'file_blur_hash': fileBlurHash,
      };

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash, imageUrl];

  static const empty = Avatar();
}
