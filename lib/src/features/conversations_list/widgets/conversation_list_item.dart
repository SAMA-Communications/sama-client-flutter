import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_client_flutter/src/shared/widget/typing_indicator.dart';

import '../../../api/api.dart';
import '../../../db/models/conversation_model.dart';
import '../../../features/conversations_list/widgets/avatar_group_icon.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversations_list_bloc.dart';
import 'avatar_letter_icon.dart';
import 'package:intl/intl.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem(
      {required this.conversation, this.typingStatus, super.key});

  final ConversationModel conversation;
  final TypingChatStatus? typingStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: conversation.type == 'u'
            ? AvatarLetterIcon(
                name: conversation.name,
                lastName: conversation.opponent?.lastName,
                avatar: conversation.avatar,
                isDeleted: isDeletedUser(conversation.opponent),
              )
            : AvatarGroupIcon(conversation.avatar),
        title: Text(
          conversation.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: BodyWidget(conversation, typingStatus),
        trailing: DateUnreadWidget(conversation: conversation),
        isThreeLine: true,
        dense: false,
        contentPadding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 4.0),
        onTap: () {
          context.go('$conversationListScreenPath/$conversationScreenSubPath',
              extra: conversation);
        },
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget(this.conversation, this.typingStatus, {super.key});

  final ConversationModel conversation;
  final TypingChatStatus? typingStatus;

  @override
  Widget build(BuildContext context) {
    String? blurHash =
        conversation.lastMessage?.attachments.firstOrNull?.fileBlurHash;
    var showTyping = typingStatus?.typingState == TypingState.start;

    if (showTyping) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: TypingIndicator(
              userName: conversation.type == 'u'
                  ? ''
                  : getUserName(typingStatus!.user)));
    } else {
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
                    child: Image(
                      image: BlurHashImage(blurHash),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (conversation.draftMessage != null)
              const TextSpan(
                text: "Draft: ",
                style: TextStyle(
                    fontWeight: FontWeight.w300, fontSize: 16, color: green),
              ),
            TextSpan(
              text: _getMessageBodyText(conversation),
              style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 16),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  String _getMessageBodyText(ConversationModel conversation) {
    if (conversation.draftMessage != null) {
      return conversation.draftMessage!.body!;
    }
    return conversation.lastMessage?.body != null
        ? conversation.lastMessage!.body!
        : "";
  }
}

class DateUnreadWidget extends StatelessWidget {
  const DateUnreadWidget({required this.conversation, super.key});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            DateFormatter().getVerboseDateTimeRepresentation(
                (conversation.lastMessage?.t != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        conversation.lastMessage!.t! * 1000)
                    : conversation.updatedAt!)),
            style: const TextStyle(color: whiteAluminum, fontSize: 15),
          ),
        ),
        if (conversation.unreadMessagesCount != null &&
            conversation.unreadMessagesCount != 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                  color: slateBlue, borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                conversation.unreadMessagesCount.toString(),
                style: const TextStyle(color: white),
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
      return DateFormat('jm').format(dateTime);
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
