import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../../../api/chats/models/message.dart';
import '../../../db/models/chat.dart';
import '../../../features/chat_list/widgets/avatar_group_icon.dart';
import '../../../api/chats/models/models.dart';
import '../../../shared/ui/colors.dart';
import 'avatar_letter_icon.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({required this.chat, super.key});

  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
            maxWidth: 64,
            maxHeight: 64,
          ),
          child: chat.type == 'u'
              ? AvatarLetterIcon(
                  name: chat.opponent?.firstName ?? chat.opponent?.login  ?? "Deleted account",
                  lastName: chat.opponent?.lastName,
                )
              : const AvatarGroupIcon(),
        ),
        title: Text(_getChatName(chat),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        subtitle: BodyWidget(message: chat.lastMessage),
        trailing: DateUnreadWidget(chat: chat),
        isThreeLine: true,
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
        onTap: () {},
      ),
    );
  }

  String _getChatName(ChatModel chat) {
    return chat.name ??
        (chat.opponent?.firstName != null && chat.opponent?.lastName != null
            ? "${chat.opponent?.firstName!} ${chat.opponent?.lastName!}"
            : chat.opponent?.firstName != null
                ? chat.opponent!.firstName!
                : chat.opponent?.login ?? "Deleted account");
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget({required this.message, super.key});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    String? blurHash = message?.attachments?.first.fileBlurHash;
    String body = message?.body != null ? message!.body! : "";

    return Text.rich(
      TextSpan(
        children: [
          if (blurHash != null)
            WidgetSpan(
              child: Container(
                width: 15.0,
                height: 15.0,
                margin: const EdgeInsets.only(right: 2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: BlurHash(
                    hash: blurHash,
                    imageFit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          TextSpan(text: body),
        ],
      ),
    );
  }
}

class DateUnreadWidget extends StatelessWidget {
  const DateUnreadWidget({required this.chat, super.key});

  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            DateFormatter().getVerboseDateTimeRepresentation(
                (chat.lastMessage?.t != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        chat.lastMessage!.t! * 1000)
                    : chat.updatedAt!)),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        if (chat.unreadMessagesCount != null && chat.unreadMessagesCount != 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                  color: slateBlue, borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                chat.unreadMessagesCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class DateFormatter {
  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = DateTime.now().subtract(const Duration(minutes: 1));

    DateTime localDateTime = dateTime.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    String roughTimeString = DateFormat('jm').format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return weekday.substring(0, 2);
    }

    return DateFormat.yMd().format(dateTime);
  }
}
