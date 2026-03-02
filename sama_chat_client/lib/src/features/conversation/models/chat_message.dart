import '../../../db/models/models.dart';

// ignore: must_be_immutable
class ChatMessage extends MessageModel {
  final bool isFirstUserMessage;
  final bool isLastUserMessage;

  ChatMessage({
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    required super.isOwn,
    required super.id,
    required super.from,
    required super.cid,
    super.bid,
    super.repliedMessageId,
    super.forwardedMessageId,
    super.status,
    super.body,
    super.createdAt,
    super.t,
    super.isTempReplied,
    super.isEdited,
    super.extension,
  });

  @override
  ChatMessage copyWith({
    bool? isFirstUserMessage,
    bool? isLastUserMessage,
    int? bid,
    String? id,
    String? from,
    String? cid,
    String? repliedMessageId,
    String? forwardedMessageId,
    MessageModelStatus? status,
    String? body,
    bool? isOwn,
    int? t,
    bool? isTempReplied,
    bool? isEdited,
    DateTime? createdAt,
    Map<String, dynamic>? extension,
    List<AttachmentModel>? attachments,
    MessageModel? replyMessage,
    UserModel? sender,
  }) {
    return ChatMessage(
        isFirstUserMessage: isFirstUserMessage ?? this.isFirstUserMessage,
        isLastUserMessage: isLastUserMessage ?? this.isLastUserMessage,
        bid: bid ?? this.bid,
        id: id ?? this.id,
        from: from ?? this.from,
        cid: cid ?? this.cid,
        repliedMessageId: repliedMessageId ?? this.repliedMessageId,
        forwardedMessageId: forwardedMessageId ?? this.forwardedMessageId,
        body: body ?? this.body,
        isOwn: isOwn ?? this.isOwn,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
        isTempReplied: isTempReplied ?? this.isTempReplied,
        isEdited: isEdited ?? this.isEdited,
        extension: extension ?? this.extension)
      ..sender = sender ?? this.sender
      ..replyMessage = replyMessage ?? this.replyMessage
      ..attachments.addAll(attachments ?? this.attachments);
  }

  @override
  String toString() {
    return 'ChatMessage{sender: $sender, isOwn: $isOwn, isFirstUserMessage: $isFirstUserMessage, isLastUserMessage: $isLastUserMessage, status: $status, attachments: $attachments ${super.toString()}';
  }

  @override
  List<Object?> get props => [
        ...super.props,
        isLastUserMessage,
        isFirstUserMessage,
        status,
        replyMessage
      ];
}

extension ChatMessageExtension on MessageModel {
  ChatMessage toChatMessage(bool isLastUserMessage, bool isFirstUserMessage) {
    return ChatMessage(
        bid: bid,
        isLastUserMessage: isLastUserMessage,
        isFirstUserMessage: isFirstUserMessage,
        id: id,
        from: from,
        cid: cid,
        repliedMessageId: repliedMessageId,
        forwardedMessageId: forwardedMessageId,
        status: status,
        body: body,
        isOwn: isOwn,
        createdAt: createdAt,
        t: t,
        extension: extension,
        isEdited: isEdited)
      ..sender = sender
      ..replyMessage = replyMessage
      ..attachments.addAll(attachments);
  }

  bool isServiceMessage() {
    return extension?['type'] != null;
  }

  bool hasAttachments() {
    return attachments.isNotEmpty;
  }
}
