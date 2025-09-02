import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../api/api.dart';
import '../../../db/models/models.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/screen_factor.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/media_attachment/media_attachment_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import '../models/models.dart';
import '../widgets/focused_popup_menu.dart';
import '../widgets/forward_messages/forward_bubble.dart';
import '../widgets/forward_messages/forward_messages_widget.dart';
import '../widgets/media_attachment.dart';
import '../widgets/reply_bubble.dart';
import '../widgets/service_message_bubble.dart';
import '../widgets/text_message_item.dart';
import '../widgets/unsupported_message.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({super.key});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final _scrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendMessageBloc, SendMessageState>(
        listener: (context, sendState) {
          if (sendState.status == SendMessageStatus.success) {
            scrollTo(0);
          }
        },
        child: Stack(children: [
          BlocBuilder<ConversationBloc, ConversationState>(
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
                  scrollToReplyIfNeed(state);
                  return NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification &&
                            notification.dragDetails != null) {
                          final keyboardTop = screenHeight - keyboardHeight();
                          var shouldClose = keyboardTop <
                              notification.dragDetails!.globalPosition.dy;
                          if (notification.scrollDelta! > 0 && shouldClose) {
                            hideKeyboard();
                          }
                        } else if (notification is ScrollEndNotification) {
                          _onScroll(notification.metrics.pixels,
                              notification.metrics.maxScrollExtent);
                        }
                        return false;
                      },
                      child: ScrollablePositionedList.separated(
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          var msg = state.messages[index];
                          return MessageItem(
                              message: msg,
                              onTapReply: () {
                                var replyIndex = state.messages.indexWhere(
                                    (item) => item.id == msg.repliedMessageId);
                                if (replyIndex == -1) {
                                  if (!state.hasReachedMax) {
                                    context.read<ConversationBloc>().add(
                                        MessagesMoreForReply(
                                            msg.repliedMessageId!));
                                    showProgress();
                                  }
                                  return;
                                }
                                scrollTo(replyIndex);
                              },
                              onTapForward: () => print('onTapForward'));
                        },
                        itemCount: state.messages.length,
                        itemScrollController: _scrollController,
                        itemPositionsListener: itemPositionsListener,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                      ));
                case ConversationStatus.initial:
                  return const Center(child: CircularProgressIndicator());
                case ConversationStatus.delete:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                  return const SizedBox.shrink();
              }
            },
          ),
          scrollFAB,
        ]));
  }

  Widget get scrollFAB => ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        bool showScrollFAB = false;
        if (positions.isNotEmpty) {
          if (positions.first.index > 0) {
            showScrollFAB = true;
          }
        }
        return Positioned(
            bottom: 16,
            right: 16,
            child: Visibility(
              visible: showScrollFAB,
              child: FloatingActionButton(
                backgroundColor: semiBlack,
                tooltip: 'Scroll',
                mini: true,
                shape: const CircleBorder(),
                onPressed: () {
                  scrollTo(0);
                },
                child: const Icon(Icons.arrow_downward_outlined,
                    color: lightMallow, size: 28),
              ),
            ));
      });

  void scrollToReplyIfNeed(ConversationState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.replyIdToScroll.isNotEmpty) {
        context
            .read<ConversationBloc>()
            .add(const RemoveMessagesMoreForReply());
        hideProgress();
        int replyIndex = state.messages
            .indexWhere((item) => item.id == state.replyIdToScroll);
        scrollTo(replyIndex);
      }
    });
  }

  void scrollTo(int msgIndex) {
    _scrollController.scrollTo(
        index: msgIndex,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutCubic);
  }

  showProgress() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
            duration: scrollToReplyTimeout,
            content: Row(children: <Widget>[
              CircularProgressIndicator(
                  strokeWidth: 2.0,
                  padding: EdgeInsets.only(right: 20),
                  valueColor: AlwaysStoppedAnimation<Color>(slateBlue)),
              Text("Loading...")
            ])),
      );
  }

  hideProgress() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void markAsReadIfNeed() {
    var conversation = context.read<ConversationBloc>().state.conversation;
    if ((conversation.unreadMessagesCount ?? 0) != 0) {
      context.read<SendMessageBloc>().add(const SendStatusReadMessages());
    }
  }

  void _onScroll(var currentScroll, var maxScroll) {
    var isTop = currentScroll >= (maxScroll * 0.8);
    if (isTop) {
      context.read<ConversationBloc>().add(const MessagesMoreRequested());
    }
  }
}

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTapReply;
  final VoidCallback? onTapForward;

  const MessageItem(
      {required this.message, this.onTapReply, this.onTapForward, super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.read<ConversationBloc>().state;

    if (message.repliedMessageId != null && message.replyMessage == null) {
      context
          .read<ConversationBloc>()
          .add(ReplyMessageRequired(message.id, message.repliedMessageId!));
    }

    return ListTile(
        dense: true,
        horizontalTitleGap: 0.0,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        minVerticalPadding: 0.0,
        onTap: state.choose && !message.isServiceMessage()
            ? () {
                toggleCheckbox(message, state, context);
              }
            : null,
        leading: state.choose && !message.isServiceMessage()
            ? Checkbox(
                shape: const CircleBorder(),
                value: state.selectedMessages.value.contains(message),
                onChanged: (checked) {
                  toggleCheckbox(message, state, context);
                })
            : null,
        title: AbsorbPointer(
            absorbing: message.isServiceMessage() || state.choose,
            child: GestureDetector(
                onLongPressStart: (details) {
                  FocusedPopupMenu(
                          menuItems: <FocusedPopupMenuItem>[
                        FocusedPopupMenuItem(
                            leadingIcon: const Icon(Icons.replay_outlined),
                            title: const Text('Reply'),
                            onPressed: () {
                              context
                                  .read<SendMessageBloc>()
                                  .add(AddReplyMessage(message));
                            }),
                        if (message.isOwn && !message.hasAttachments())
                          FocusedPopupMenuItem(
                              leadingIcon: const Icon(Icons.edit_outlined),
                              title: const Text('Edit'),
                              onPressed: () {
                                print('edit message= ${message.body}');
                                context
                                    .read<SendMessageBloc>()
                                    .add(AddEditMessage(message));
                              }),
                        FocusedPopupMenuItem(
                            leadingIcon:
                                const Icon(Icons.delete_forever_outlined),
                            title: const Text('Delete'),
                            onPressed: () {
                              print('delete message= ${message.body}');
                            }),
                        FocusedPopupMenuItem(
                            leadingIcon: const Icon(Icons.forward_outlined),
                            title: const Text('Forward'),
                            onPressed: () {
                              print('forward message= ${message.body}');
                              showModalBottomSheet<dynamic>(
                                  isScrollControlled: true,
                                  useSafeArea: false,
                                  context: context,
                                  backgroundColor: black,
                                  builder: (BuildContext bc) {
                                    return Container(
                                        color: lightWhite,
                                        margin: EdgeInsets.only(
                                            top: MediaQueryData.fromView(
                                                    View.of(context))
                                                .padding
                                                .top),
                                        child: BlocProvider.value(
                                          value:
                                              BlocProvider.of<ConversationBloc>(
                                                  context),
                                          child:
                                              ForwardMessagesWidget({message}),
                                        ));
                                  });
                            }),
                        FocusedPopupMenuItem(
                            leadingIcon: const Icon(Icons.check_circle_outline),
                            title: const Text('Select'),
                            onPressed: () {
                              print('select message= ${message.body}');
                              context
                                  .read<ConversationBloc>()
                                  .add(ChooseMessages(true, message: message));
                            }),
                      ],
                          context: context,
                          child: MultiBlocProvider(providers: [
                            BlocProvider.value(
                                value: BlocProvider.of<MediaAttachmentBloc>(
                                    context)),
                            BlocProvider.value(
                                value:
                                    BlocProvider.of<ConversationBloc>(context)),
                          ], child: this),
                          stickToRight: message.isOwn)
                      .show();
                },
                child: Column(
                    crossAxisAlignment: message.isOwn
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.forwardedMessageId != null)
                        ForwardBubble(message: message, onTap: onTapForward)
                      else if (message.repliedMessageId != null)
                        ReplyBubble(message: message, onTap: onTapReply),
                      buildMessageListItem(message, context),
                    ]))));
  }

  void toggleCheckbox(
      ChatMessage msg, ConversationState state, BuildContext context) {
    if (state.selectedMessages.value.contains(msg)) {
      context.read<ConversationBloc>().add(SelectedChatsRemoved(msg));
    } else {
      context.read<ConversationBloc>().add(SelectedChatsAdded(msg));
    }
  }

  Widget buildMessageListItem(ChatMessage message, BuildContext context) {
    if (message.hasAttachments()) {
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
