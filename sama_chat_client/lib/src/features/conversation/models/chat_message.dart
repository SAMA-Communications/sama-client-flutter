import '../../../db/models/models.dart';
import '../../../shared/utils/list_utils.dart';

enum BubbleType { common, upper, middle, lower }

// ignore: must_be_immutable
class ChatMessage extends MessageModel {
  final bool isFirstUserMessage;
  final bool isLastUserMessage;
  final BubbleType bubbleType;

  ChatMessage({
    required this.isFirstUserMessage,
    required this.isLastUserMessage,
    required this.bubbleType,
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
    BubbleType? bubbleType,
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
        bubbleType: bubbleType ?? this.bubbleType,
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
  ChatMessage toChatMessage(
      bool isLastUserMessage, bool isFirstUserMessage, BubbleType bubbleType) {
    return ChatMessage(
        bid: bid,
        isLastUserMessage: isLastUserMessage,
        isFirstUserMessage: isFirstUserMessage,
        bubbleType: bubbleType,
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

bool sameMsgGroup(MessageModel msg, MessageModel? other) {
  int diffTime = 30;

  bool isSameOwner = (other?.isOwn ?? false) && msg.isOwn ||
      (!(other?.isOwn ?? false)) && !msg.isOwn;

  var otherMs = (other?.createdAt?.millisecondsSinceEpoch ?? 0) ~/ 1000;
  var msgMs = (msg.createdAt?.millisecondsSinceEpoch ?? 0) ~/ 1000;
  var timeGap = (msgMs - otherMs).abs();

  return isSameOwner && timeGap < diffTime;
}

BubbleType bubbleType(List<MessageModel> messages, int index) {
  MessageModel currentMsg = messages[index];
  MessageModel? prevMsg = messages.tryGet(index + 1);
  MessageModel? nextMsg = messages.tryGet(index - 1);

  var prevSame = sameMsgGroup(currentMsg, prevMsg);
  var nextSame = sameMsgGroup(currentMsg, nextMsg);

  BubbleType bubbleType = prevSame && nextSame
      ? BubbleType.middle
      : prevSame
          ? BubbleType.upper
          : nextSame
              ? BubbleType.lower
              : BubbleType.common;

  return bubbleType;
}
