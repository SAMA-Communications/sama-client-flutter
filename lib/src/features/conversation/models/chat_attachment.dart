import '../../../db/models/attachment_model.dart';

// ignore_for_file: must_be_immutable
class ChatAttachment extends AttachmentModel {
  String? url;

  ChatAttachment({
    this.url,
    super.fileId,
    super.fileName,
    super.fileBlurHash,
  });


  @override
  List<Object?> get props => [
    ...super.props, url
  ];
}

extension ChatAttachmentExtension on AttachmentModel {
  ChatAttachment toChatAttachment([String? url]) => ChatAttachment(
      url: url, fileId: fileId, fileName: fileName, fileBlurHash: fileBlurHash);
}
