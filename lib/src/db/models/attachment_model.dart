import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../api/conversations/models/models.dart';

@Entity()
// ignore: must_be_immutable
class AttachmentModel extends Equatable {
  @Id()
  int? bid;
  @Unique(onConflict: ConflictStrategy.replace)
  final String? fileId;
  final String? fileName;
  final String? fileBlurHash;
  final String? url;
  final String? contentType;
  final int? fileHeight;
  final int? fileWidth;

  AttachmentModel({
    this.bid,
    this.fileId,
    this.fileName,
    this.fileBlurHash,
    this.url,
    this.contentType,
    this.fileHeight,
    this.fileWidth,
  });

  AttachmentModel copyWith({
    int? bid,
    String? fileId,
    String? fileName,
    String? fileBlurHash,
    String? url,
    String? contentType,
    int? fileHeight,
    int? fileWidth,
  }) {
    return AttachmentModel(
        bid: bid ?? this.bid,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
        fileBlurHash: fileBlurHash ?? this.fileBlurHash,
        url: url ?? this.url,
        contentType: contentType ?? this.contentType,
        fileHeight: fileHeight ?? this.fileHeight,
        fileWidth: fileWidth ?? this.fileWidth);
  }

  @override
  String toString() {
    return 'AttachmentModel{bid: $bid, fileId: $fileId, fileName: $fileName, fileBlurHash: $fileBlurHash, '
        'url: $url, contentType: $contentType, fileHeight: $fileHeight, fileWidth: $fileWidth}';
  }

  @override
  List<Object?> get props =>
      [fileId, fileName, fileBlurHash, url, contentType, fileHeight, fileWidth];
}

extension AttachmentModelExtension on Attachment {
  AttachmentModel toAttachmentModel() {
    return AttachmentModel(
        fileId: fileId,
        fileName: fileName,
        fileBlurHash: fileBlurHash,
        url: fileUrl,
        contentType: fileContentType,
        fileHeight: fileHeight,
        fileWidth: fileWidth);
  }
}
