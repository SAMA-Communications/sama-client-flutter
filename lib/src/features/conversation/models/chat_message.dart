import '../../../api/api.dart';

enum ChatMessageStatus { none, pending, sent, read }

class ChatMessage extends Message {
  final User sender;
  final bool isOwn;
  final bool isFirstUserMessage;
  final bool isLastUserMessage;
  final ChatMessageStatus status;

  const ChatMessage({
    required this.sender,
    required this.isOwn,
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    this.status = ChatMessageStatus.none,
    super.id,
    super.from,
    super.cid,
    super.rawStatus,
    super.body,
    super.attachments,
    super.createdAt,
    super.t,
    super.extension,
  });

  ChatMessage copyWith({
    User? sender,
    bool? isOwn,
    bool? isFirstUserMessage,
    bool? isLastUserMessage,
    ChatMessageStatus? status,
    String? id,
    String? from,
    String? cid,
    String? rawStatus,
    String? body,
    List<Attachment>? attachments,
    int? t,
    DateTime? createdAt,
    Map<String, dynamic>? extension,
  }) {
    return ChatMessage(
      sender: sender ?? this.sender,
      isOwn: isOwn ?? this.isOwn,
      isFirstUserMessage: isFirstUserMessage ?? this.isFirstUserMessage,
      isLastUserMessage: isLastUserMessage ?? this.isLastUserMessage,
      status: status ?? this.status,
      id: id ?? this.id,
      from: from ?? this.from,
      cid: cid ?? this.cid,
      body: body ?? this.body,
      rawStatus: rawStatus ?? this.rawStatus,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      t: t ?? this.t,
      extension: extension ?? this.extension,
    );
  }

  @override
  List<Object?> get props =>
      [...super.props, isLastUserMessage, isFirstUserMessage, status];
}

extension ChatMessageExtension on Message {
  ChatMessage toChatMessage(
      User sender, bool isOwn, bool isLastUserMessage, bool isFirstUserMessage,
      [ChatMessageStatus status = ChatMessageStatus.none]) {
    return ChatMessage(
        sender: sender,
        isOwn: isOwn,
        isLastUserMessage: isLastUserMessage,
        isFirstUserMessage: isFirstUserMessage,
        status: rawStatus == 'read' ? ChatMessageStatus.read : status,
        id: id,
        from: from,
        cid: cid,
        rawStatus: rawStatus,
        body: body,
        attachments: attachments,
        createdAt: createdAt,
        t: t,
        extension: extension);
  }
}
