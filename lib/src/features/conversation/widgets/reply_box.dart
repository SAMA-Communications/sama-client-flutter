import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../models/chat_message.dart';

class ReplyBox extends StatelessWidget {
  final ChatMessage replyMessage;

  const ReplyBox({super.key, required this.replyMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: gainsborough,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Reply to ${replyMessage.isOwn ? 'you' : getUserName(replyMessage.sender)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: slateBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              IconButton(
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                alignment: Alignment.topRight,
                // padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                icon: const Icon(
                  Icons.close,
                  color: black,
                  size: 20,
                ),
                onPressed: () {
                  BlocProvider.of<ConversationBloc>(context)
                      .add(const RemoveReplyMessage());
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: ReplyMessageView(
              message: replyMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ReplyMessageView extends StatelessWidget {
  const ReplyMessageView({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.attachments.isNotEmpty) {
      return const Row(
        children: [
          Icon(
            Icons.photo,
            size: 20,
            color: dullGray,
          ),
          Text(
            'attachment',
            style: TextStyle(
              color: black,
            ),
          ),
        ],
      );
    } else {
      return Text(
        message.body!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: black,
        ),
      );
    }
  }
}
