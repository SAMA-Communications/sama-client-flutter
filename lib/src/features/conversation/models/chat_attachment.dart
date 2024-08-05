import 'package:sama_client_flutter/src/api/conversations/models/models.dart';

// ignore_for_file: must_be_immutable
class ChatAttachment extends Attachment {
  String? url;

  ChatAttachment({
    this.url,
    super.fileId,
    super.fileName,
    super.fileBlurHash,
  });
}

extension ChatAttachmentExtension on Attachment {
  ChatAttachment toChatAttachment([String? url]) => ChatAttachment(
      url: url, fileId: fileId, fileName: fileName, fileBlurHash: fileBlurHash);
}
