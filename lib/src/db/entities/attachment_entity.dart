import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// ignore: must_be_immutable
class AttachmentEntity extends Equatable {
  @Id()
  int? id;
  @Unique()
  final String? fileId;
  final String? fileName;
  final String? fileBlurHash;

  AttachmentEntity({
    this.id,
    this.fileId,
    this.fileName,
    this.fileBlurHash,
  });

  @override
  List<Object?> get props => [fileId, fileName, fileBlurHash];
}
