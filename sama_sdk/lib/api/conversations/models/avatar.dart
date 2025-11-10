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

  Avatar.fromJson(Map<String, dynamic>? json, this.imageUrl)
      : fileId = json?['file_id'],
        fileName = json?['file_name'],
        fileBlurHash = json?['file_blur_hash'];

  Map<String, dynamic> toImageObjectJson() => {
        'file_id': fileId,
        'file_name': fileName,
        'file_blur_hash': fileBlurHash,
      };

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash, imageUrl];

  Avatar copyWith({
    String? fileId,
    String? fileName,
    String? fileBlurHash,
    String? imageUrl,
  }) {
    return Avatar(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      fileBlurHash: fileBlurHash ?? this.fileBlurHash,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static const empty = Avatar();
}
