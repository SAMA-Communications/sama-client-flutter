import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../api/conversations/models/models.dart';

@Entity()
// ignore: must_be_immutable
class AvatarModel extends Equatable {
  @Id()
  int? bid;
  @Unique(onConflict: ConflictStrategy.replace)
  final String? fileId;
  final String? fileName;
  final String? fileBlurHash;
  final String? imageUrl;

  AvatarModel({
    this.bid,
    this.fileId,
    this.fileName,
    this.fileBlurHash,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash, imageUrl];
}

extension AvatarModelExtension on Avatar {
  AvatarModel toAvatarModel() {
    return AvatarModel(
        fileId: fileId,
        fileName: fileName,
        fileBlurHash: fileBlurHash,
        imageUrl: imageUrl);
  }
}
