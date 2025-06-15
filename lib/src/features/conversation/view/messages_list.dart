import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../api/api.dart';
import '../../../db/models/models.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import '../models/models.dart';
import '../widgets/media_attachment.dart';
import '../widgets/reply_message_widget.dart';
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
            WidgetsBinding.instance
                .addPostFrameCallback((_) => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                        content: Text(
                            'The chat update is unavailable. Please check your Internet connection.')),
                  ));
            continue success;
          success:
          case ConversationStatus.success:
            if (state.messages.isEmpty) {
              return state.initial
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: const Text(
                          'Write the first message...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
            }
            markAsReadIfNeed();
            return ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                return MessageItem(message: state.messages[index]);
              },
              itemCount: state.messages.length,
              controller: _scrollController,
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) => const SizedBox(
                height: 5,
              ),
            );
          case ConversationStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case ConversationStatus.delete:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.popUntil(context, (route) => route.isFirst);
            });
            return const SizedBox.shrink();
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

  void markAsReadIfNeed() {
    var conversation = context.read<ConversationBloc>().state.conversation;
    if ((conversation.unreadMessagesCount ?? 0) != 0) {
      context.read<SendMessageBloc>().add(const SendStatusReadMessages());
    }
  }

  void _onScroll() {
    if (_isTop) {
      context.read<ConversationBloc>().add(const MessagesMoreRequested());
    }
  }

  bool get _isTop {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class MessageItem extends StatelessWidget {
  final ChatMessage message;

  const MessageItem({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey key = GlobalKey(debugLabel: 'key_${message.id!}');
    final shouldAbsorb = message.isServiceMessage();

    return AbsorbPointer(
        absorbing: shouldAbsorb,
        child: GestureDetector(
            onLongPressStart: (details) {
              PopupMessageMenu(
                  context: context,
                  onClickMenu: (MessageMenuItem item) {
                    switch (item) {
                      case MessageMenuItem.reply:
                        print('reply message= ${message.body}');
                        context
                            .read<ConversationBloc>()
                            .add(ConversationReply(message));
                        break;
                      case MessageMenuItem.edit:
                        print('edit message= ${message.body}');
                        break;
                      case MessageMenuItem.delete:
                        print('delete message= ${message.body}');
                        break;
                      case MessageMenuItem.forward:
                        print('forward message= ${message.body}');
                        break;
                    }
                  }).show(details.globalPosition);
            },
            child: Column(
                crossAxisAlignment: message.isOwn
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!message.isOwn /*replyMessage.isNotEmpty*/)
                    ReplyMessageWidget(message: message, onTap: () => {}),
                  buildMessageListItem(message, context),
                ])));
  }

  Widget buildMessageListItem(ChatMessage message, BuildContext context) {
    if (message.attachments.isNotEmpty) {
      try {
        return MediaAttachment.create(
          message: message,
        );
      } catch (_) {
        return UnsupportedMessage(message: message);
      }
    } else if (message.isServiceMessage()) {
      var type = message.extension?['type'];

      String notification;

      switch (type) {
        case 'added_participant':
          notification = ' has been added to the group';
          break;

        case 'removed_participant':
          notification = ' has been removed from the group';
          break;

        case 'left_participants':
          notification = ' has left the group';
          break;

        case 'update_image':
          notification = 'Group chat image was updated';
          break;

        case 'create':
          notification = ' created a new conversation';
          break;

        case 'update':
          notification = ' added you to conversation';
          break;

        case 'delete':
          notification = ' removed you from conversation';
          break;

        default:
          notification = '';
      }

      UserModel? initiator;

      if (message.extension?['user'] != null) {
        initiator = User.fromJson((message.extension?['user'])).toUserModel();
      }

      return ServiceMessageBubble(
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              if (initiator != null)
                TextSpan(
                    text: getUserName(initiator),
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

enum MessageMenuItem { reply, edit, delete, forward }

typedef MenuClickCallback = void Function(MessageMenuItem item);

class PopupMessageMenu {
  List<PopupMenuEntry<MessageMenuItem>>? items;

  final MenuClickCallback? onClickMenu;

  BuildContext context;

  PopupMessageMenu({required this.context, this.onClickMenu});

  void show(Offset offset) {
    showMenu(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      items: [
        const PopupMenuItem<MessageMenuItem>(
          padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          value: MessageMenuItem.reply,
          child: ListTile(
            leading: Icon(Icons.replay_outlined),
            title: Text('Reply'),
          ),
        ),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
            )),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.delete,
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined),
              title: Text('Delete'),
            )),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.forward,
            child: ListTile(
              leading: Icon(Icons.forward_outlined),
              title: Text('Forward'),
            )),
      ],
      context: context,
    ).then((selected) {
      if (selected != null) onClickMenu?.call(selected);
    });
  }
}
