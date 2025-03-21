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

  AttachmentModel({
    this.bid,
    this.fileId,
    this.fileName,
    this.fileBlurHash,
  });

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash];
}

extension AttachmentModelExtension on Attachment {
  AttachmentModel toAttachmentModel() {
    return AttachmentModel(
        fileId: fileId, fileName: fileName, fileBlurHash: fileBlurHash);
  }
}
