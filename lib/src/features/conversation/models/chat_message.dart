import '../../../api/api.dart';

class ChatMessage extends Message {
  final User sender;
  final bool isOwn;
  final bool isFirstUserMessage;
  final bool isLastUserMessage;

  const ChatMessage({
    required this.sender,
    required this.isOwn,
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    super.id,
    super.from,
    super.cid,
    super.status,
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
    String? id,
    String? from,
    String? cid,
    String? status,
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
      id: id ?? this.id,
      from: from ?? this.from,
      cid: cid ?? this.cid,
      status: status ?? this.status,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      t: t ?? this.t,
      extension: extension ?? this.extension,
    );
  }

  @override
  List<Object?> get props =>
      [...super.props, isLastUserMessage, isFirstUserMessage];
}
