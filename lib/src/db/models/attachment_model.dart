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

  AttachmentModel({
    this.bid,
    this.fileId,
    this.fileName,
    this.fileBlurHash,
    this.url,
  });

  AttachmentModel copyWith({
    int? bid,
    String? fileId,
    String? fileName,
    String? fileBlurHash,
    String? url,
  }) {
    return AttachmentModel(
        bid: bid ?? this.bid,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
        fileBlurHash: fileBlurHash ?? this.fileBlurHash,
        url: url ?? this.url);
  }

  @override
  String toString() {
    return 'AttachmentModel{bid: $bid, fileId: $fileId, fileName: $fileName, fileBlurHash: $fileBlurHash, url: $url}';
  }

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash, url];
}

extension AttachmentModelExtension on Attachment {
  AttachmentModel toAttachmentModel() {
    return AttachmentModel(
        fileId: fileId,
        fileName: fileName,
        fileBlurHash: fileBlurHash,
        url: fileUrl);
  }
}
