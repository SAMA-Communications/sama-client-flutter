import '../../../db/models/models.dart';

enum ChatMessageStatus { none, pending, draft, sent, read }

// ignore: must_be_immutable
class ChatMessage extends MessageModel {
  final UserModel sender;
  final bool isOwn;
  final bool isFirstUserMessage;
  final bool isLastUserMessage;
  final ChatMessageStatus status;

  ChatMessage({
    required this.sender,
    required this.isOwn,
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    this.status = ChatMessageStatus.none,
    super.bid,
    super.id,
    super.from,
    super.cid,
    super.rawStatus,
    super.body,
    super.createdAt,
    super.t,
    super.extension,
  });

  @override
  ChatMessage copyWith({
    UserModel? sender,
    bool? isOwn,
    bool? isFirstUserMessage,
    bool? isLastUserMessage,
    ChatMessageStatus? status,
    int? bid,
    String? id,
    String? from,
    String? cid,
    String? rawStatus,
    String? body,
    int? t,
    DateTime? createdAt,
    Map<String, dynamic>? extension,
    List<AttachmentModel>? attachments,
  }) {
    return ChatMessage(
        sender: sender ?? this.sender,
        isOwn: isOwn ?? this.isOwn,
        isFirstUserMessage: isFirstUserMessage ?? this.isFirstUserMessage,
        isLastUserMessage: isLastUserMessage ?? this.isLastUserMessage,
        status: status ?? this.status,
        bid: bid ?? this.bid,
        id: id ?? this.id,
        from: from ?? this.from,
        cid: cid ?? this.cid,
        body: body ?? this.body,
        rawStatus: rawStatus ?? status?.name ?? this.rawStatus,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
        extension: extension ?? this.extension)
      ..attachments.addAll(attachments ?? this.attachments);
  }

  @override
  String toString() {
    return 'ChatMessage{sender: $sender, isOwn: $isOwn, isFirstUserMessage: $isFirstUserMessage, isLastUserMessage: $isLastUserMessage, status: $status, attachments: $attachments ${super.toString()}';
  }

  @override
  List<Object?> get props =>
      [...super.props, isLastUserMessage, isFirstUserMessage, status];
}

extension ChatMessageExtension on MessageModel {
  ChatMessage toChatMessage(UserModel sender, bool isOwn,
      bool isLastUserMessage, bool isFirstUserMessage,
      [ChatMessageStatus status = ChatMessageStatus.none]) {
    return ChatMessage(
        bid: bid,
        sender: sender,
        isOwn: isOwn,
        isLastUserMessage: isLastUserMessage,
        isFirstUserMessage: isFirstUserMessage,
        status: rawStatus == ChatMessageStatus.read.name
            ? ChatMessageStatus.read
            : rawStatus == ChatMessageStatus.pending.name
                ? ChatMessageStatus.pending
                : rawStatus == ChatMessageStatus.draft.name
                    ? ChatMessageStatus.draft
                    : status,
        id: id,
        from: from,
        cid: cid,
        rawStatus: rawStatus,
        body: body,
        createdAt: createdAt,
        t: t,
        extension: extension)
      ..attachments.addAll(attachments);
  }
}
