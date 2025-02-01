import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// ignore: must_be_immutable
class AttachmentModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
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
