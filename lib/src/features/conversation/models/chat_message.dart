import '../../../db/models/models.dart';

enum ChatMessageStatus { none, pending, draft, sent, read }

// ignore: must_be_immutable
class ChatMessage extends MessageModel {
  final bool isFirstUserMessage;
  final bool isLastUserMessage;
  final ChatMessageStatus status;

  ChatMessage({
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    required super.isOwn,
    required super.id,
    required super.from,
    required super.cid,
    this.status = ChatMessageStatus.none,
    super.bid,
    super.repliedMessageId,
    super.rawStatus,
    super.body,
    super.createdAt,
    super.t,
    super.extension,
  });

  @override
  ChatMessage copyWith({
    bool? isFirstUserMessage,
    bool? isLastUserMessage,
    ChatMessageStatus? status,
    int? bid,
    String? id,
    String? from,
    String? cid,
    String? repliedMessageId,
    String? rawStatus,
    String? body,
    bool? isOwn,
    int? t,
    DateTime? createdAt,
    Map<String, dynamic>? extension,
    List<AttachmentModel>? attachments,
    MessageModel? replyMessage,
    UserModel? sender,
  }) {
    return ChatMessage(
        isFirstUserMessage: isFirstUserMessage ?? this.isFirstUserMessage,
        isLastUserMessage: isLastUserMessage ?? this.isLastUserMessage,
        status: status ?? this.status,
        bid: bid ?? this.bid,
        id: id ?? this.id,
        from: from ?? this.from,
        cid: cid ?? this.cid,
        repliedMessageId: repliedMessageId ?? this.repliedMessageId,
        body: body ?? this.body,
        isOwn: isOwn ?? this.isOwn,
        rawStatus: rawStatus ?? status?.name ?? this.rawStatus,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
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
        //consider move ChatMessageStatus enum to model base
        status: rawStatus != null
            ? ChatMessageStatus.values.byName(rawStatus!)
            : isOwn
                ? ChatMessageStatus.sent
                : ChatMessageStatus.none,
        id: id,
        from: from,
        cid: cid,
        repliedMessageId: repliedMessageId,
        rawStatus: rawStatus,
        body: body,
        isOwn: isOwn,
        createdAt: createdAt,
        t: t,
        extension: extension)
      ..sender = sender
      ..replyMessage = replyMessage
      ..attachments.addAll(attachments);
  }

  bool isServiceMessage() {
    return extension?['type'] != null;
  }

  bool isHasAttachments() {
    return attachments.isNotEmpty;
  }
}
