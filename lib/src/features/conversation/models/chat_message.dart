import '../../../api/conversations/models/models.dart';
import '../../../api/users/models/models.dart';

class ChatMessage extends Message {
  final User sender;
  final bool isOwn;
  final bool isFirst;
  final bool isLast;

  const ChatMessage({
    required this.sender,
    required this.isOwn,
    required this.isFirst,
    required this.isLast,
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
}
