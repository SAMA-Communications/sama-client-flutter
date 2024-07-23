import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../models/models.dart';
import '../widgets/images_attachment.dart';
import '../widgets/service_message_bubble.dart';
import '../widgets/text_message_item.dart';
import '../widgets/unsupported_message.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({super.key});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        switch (state.status) {
          case ConversationStatus.failure:
            return const Center(child: Text('failed to fetch messages'));
          case ConversationStatus.success:
            if (state.messages.isEmpty) {
              return const Center(child: Text('no messages'));
            }
            return ListView.separated(
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                return buildMessageListItem(state.messages[index]);
              },
              itemCount: state.messages.length,
              controller: _scrollController,
              separatorBuilder: (context, index) => const SizedBox(
                height: 5,
              ),
            );
          case ConversationStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isTop) {
      context.read<ConversationBloc>().add(const MessagesRequested());
    }
  }

  bool get _isTop {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget buildMessageListItem(ChatMessage message) {
    if (message.attachments?.isNotEmpty ?? false) {
      try {
        return ImagesAttachment.create(
          message: message,
        );
      } catch (_) {
        return UnsupportedMessage(message: message);
      }
    } else if (message.extension?['type'] != null) {
      var type = message.extension?['type'];

      String notification;

      switch (type) {
        case 'added_participant':
          notification = ' has been added to the group';
          break;

        case 'removed_participant':
          notification = ' has been removed from the group';
          break;

        default:
          notification = '';
      }

      var user = User.fromJson((message.extension?['user']));
      return ServiceMessageBubble(
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                  text: getUserName(user),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: notification,
              ),
            ],
          ),
        ),
      );
    }

    return TextMessageItem(message: message);
  }
}
