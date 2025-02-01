import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
// ignore: must_be_immutable
class AvatarModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
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
