import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../../shared/widget/keyboard_listener.dart';
import '../bloc/ai_message/ai_message_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import '../widgets/header_input_box.dart';
import 'media_sender.dart';

class MessageInput extends StatefulWidget {
  final SharedMediaFile? sharedMessage;

  const MessageInput({super.key, this.sharedMessage});

  @override
  State<StatefulWidget> createState() {
    return _MessageInputState();
  }
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController textEditingController =
      TextEditingController(
          text: widget.sharedMessage?.type == SharedMediaType.text ||
                  widget.sharedMessage?.type == SharedMediaType.url
              ? widget.sharedMessage?.path
              : null);

  final FocusNode showFocusNode = FocusNode();
  BuildContext? dialogContext;

  @override
  void initState() {
    super.initState();
    if (widget.sharedMessage?.type == SharedMediaType.image) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMedia(widget.sharedMessage?.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var showReply = false;
    var showEdit = false;
    if (widget.sharedMessage?.type == SharedMediaType.text ||
        widget.sharedMessage?.type == SharedMediaType.url) {
      BlocProvider.of<SendMessageBloc>(context)
          .add(TextMessageChanged(widget.sharedMessage!.path));
    }
    return MultiBlocListener(
      listeners: [
        BlocListener<SendMessageBloc, SendMessageState>(
          listener: (context, state) {
            if (state.status == SendMessageStatus.processing) {
              textEditingController.clear();
            } else if (state.status == SendMessageStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                      content: Text(state.errorMessage ??
                          'Can\'t send message due to some error(s)')),
                );
            }
          },
        ),
        BlocListener<SendMessageBloc, SendMessageState>(
          listenWhen: (previous, current) {
            return (previous.draftMessage != current.draftMessage ||
                    previous.replyMessage != current.replyMessage ||
                    previous.editMessage != current.editMessage) &&
                widget.sharedMessage == null;
          },
          listener: (context, state) {
            showReply = state.replyMessage != null;
            if (showReply) showFocusNode.requestFocus();

            showEdit = state.editMessage != null;
            if (showEdit) {
              showFocusNode.requestFocus();
              textEditingController.text = state.editMessage!.body!;
            }

            if (state.draftMessage != null) {
              textEditingController.text = state.draftMessage!.body!;
            }
          },
        ),
        BlocListener<AiMessageBloc, AiMessageState>(
          listenWhen: (previous, current) {
            return (previous.text != current.text);
          },
          listener: (context, state) {
            textEditingController.text = state.text;
          },
        )
      ],
      child: BlocBuilder<SendMessageBloc, SendMessageState>(
        builder: (rootContext, state) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            if (showReply)
              HeaderInputBox(
                  message: state.replyMessage!,
                  title:
                      'Reply to ${state.replyMessage!.isOwn ? 'you' : getUserName(state.replyMessage!.sender)}',
                  onTap: () {
                    BlocProvider.of<SendMessageBloc>(context)
                        .add(const RemoveReplyMessage());
                  },
                  icon: const Icon(Icons.replay_outlined)),
            if (showEdit)
              HeaderInputBox(
                message: state.editMessage!,
                title: 'Editing',
                onTap: () {
                  textEditingController.clear();
                  BlocProvider.of<SendMessageBloc>(context)
                      .add(const RemoveEditMessage());
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            Container(
              constraints: const BoxConstraints(maxHeight: 120.0),
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                color: gainsborough,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_outlined),
                    color: dullGray,
                    onPressed: () {
                      connectionChecker(context, () => showMedia());
                    },
                  ),
                  Flexible(
                    child: TextField(
                      focusNode: showFocusNode,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: dullGray),
                      ),
                      onChanged: (text) {
                        BlocProvider.of<SendMessageBloc>(rootContext)
                            .add(TextMessageChanged(text));
                        BlocProvider.of<SendMessageBloc>(rootContext)
                            .add(const SendTypingChanged());
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: state.isTextEmpty
                        ? null
                        : () => onSendChatMessage(
                            rootContext, textEditingController.text),
                    color: dullGray,
                  ),
                  _MagicMenuButton(textEditingController)
                ],
              ),
            )
          ]);
        },
      ),
    );
  }

  void onSendChatMessage(BuildContext context, String text) {
    BlocProvider.of<SendMessageBloc>(context).add(SendTextMessage(text));
    if (context.read<SendMessageBloc>().state.draftMessage != null) {
      BlocProvider.of<SendMessageBloc>(context).add(const RemoveDraftMessage());
    }
    if (context.read<SendMessageBloc>().state.replyMessage != null) {
      BlocProvider.of<SendMessageBloc>(context).add(const RemoveReplyMessage());
    }
    if (context.read<SendMessageBloc>().state.editMessage != null) {
      BlocProvider.of<SendMessageBloc>(context).add(const RemoveEditMessage());
    }
  }

  showMedia([String? path]) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            content: SizedBox(
              width: double.maxFinite,
              child: MediaSender.create(
                  currentConversation:
                      context.watch<SendMessageBloc>().currentConversation,
                  replyMessage: BlocProvider.of<SendMessageBloc>(context)
                      .state
                      .replyMessage,
                  path: path),
            ));
      },
    );
  }

  @override
  void dispose() {
    if (dialogContext != null && dialogContext!.mounted) dialogContext!.pop();
    showFocusNode.dispose();
    super.dispose();
  }
}

enum AIMainMenuItem { mainSummary, messageTone }

enum AISubSumMenuItem {
  subUnread,
  subLastDay,
  subLast7days,
}

enum AISubToneMenuItem {
  subPositive,
  subNegative,
  subCringe,
}

class _MagicMenuButton extends StatefulWidget {
  final TextEditingController textEditingController;

  const _MagicMenuButton(this.textEditingController);

  @override
  State<_MagicMenuButton> createState() => _MagicMenuButtonState();
}

class _MagicMenuButtonState extends State<_MagicMenuButton> {
  final subMenuPad = 32.0;
  IconData iconData = Icons.arrow_drop_up_outlined;
  var mainMenuIsOpen = false;
  var submenuIsOpen = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityListener(
        listener: (isKeyboardVisible) {
          if (!isKeyboardVisible) {
            // FocusManager.instance.primaryFocus?.unfocus();
            if (submenuIsOpen) Navigator.pop(context);
            if (mainMenuIsOpen) Navigator.pop(context);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton<AIMainMenuItem>(
                constraints: const BoxConstraints.tightFor(width: 150),
                popUpAnimationStyle: AnimationStyle.noAnimation,
                requestFocus: false,
                offset: Offset(2.0, -estimatedMenuHeight(2)),
                tooltip: "",
                onOpened: () {
                  mainMenuIsOpen = true;
                },
                onCanceled: () {
                  mainMenuIsOpen = false;
                },
                onSelected: (value) {
                  mainMenuIsOpen = false;
                },
                itemBuilder: (BuildContext rootContext) =>
                    <PopupMenuEntry<AIMainMenuItem>>[
                      PopupMenuItem<AIMainMenuItem>(
                        value: AIMainMenuItem.mainSummary,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return PopupMenuButton<AISubSumMenuItem>(
                            popUpAnimationStyle: AnimationStyle.noAnimation,
                            requestFocus: false,
                            offset: Offset(12.0, -estimatedMenuHeight(2)),
                            tooltip: "",
                            onOpened: () {
                              submenuIsOpen = true;
                              setState(() =>
                                  iconData = Icons.arrow_drop_down_outlined);
                            },
                            onCanceled: () {
                              submenuIsOpen = false;
                              setState(() =>
                                  iconData = Icons.arrow_drop_up_outlined);
                            },
                            onSelected: (subValue) {
                              switch (subValue) {
                                case AISubSumMenuItem.subUnread:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(const GetMessagesSummary('unreads'));
                                  break;
                                case AISubSumMenuItem.subLastDay:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(
                                          const GetMessagesSummary('last-day'));
                                  break;
                                case AISubSumMenuItem.subLast7days:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(const GetMessagesSummary(
                                          'last-7-days'));
                                  break;
                              }
                              submenuIsOpen = false;
                              iconData = Icons.arrow_drop_up_outlined;
                              Navigator.pop(context); //close main menu
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<AISubSumMenuItem>>[
                              //     comment for now
                              // PopupMenuItem<AISubSumMenuItem>(
                              //     value: AISubSumMenuItem.subUnread,
                              //     padding: EdgeInsets.only(left: subMenuPad),
                              //     child: const Text('unreads')),
                              PopupMenuItem<AISubSumMenuItem>(
                                value: AISubSumMenuItem.subLastDay,
                                padding: EdgeInsets.only(left: subMenuPad),
                                child: const Text('last day'),
                              ),
                              PopupMenuItem<AISubSumMenuItem>(
                                value: AISubSumMenuItem.subLast7days,
                                padding: EdgeInsets.only(left: subMenuPad),
                                child: const Text('7 days'),
                              ),
                            ],
                            child: ListTile(
                              horizontalTitleGap: 0,
                              title: const Align(
                                alignment: Alignment(0.5, 0),
                                child: Text('Get summary'),
                              ),
                              trailing: Icon(iconData),
                            ),
                          );
                        }),
                      ),
                      PopupMenuItem<AIMainMenuItem>(
                        enabled: widget.textEditingController.text.isNotEmpty,
                        value: AIMainMenuItem.messageTone,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return PopupMenuButton<AISubToneMenuItem>(
                            enabled:
                                widget.textEditingController.text.isNotEmpty,
                            popUpAnimationStyle: AnimationStyle.noAnimation,
                            requestFocus: false,
                            offset: Offset(12.0, -estimatedMenuHeight(3)),
                            tooltip: "",
                            onOpened: () {
                              submenuIsOpen = true;
                              setState(() =>
                                  iconData = Icons.arrow_drop_down_outlined);
                            },
                            onCanceled: () {
                              submenuIsOpen = false;
                              setState(() =>
                                  iconData = Icons.arrow_drop_up_outlined);
                            },
                            onSelected: (subValue) {
                              switch (subValue) {
                                case AISubToneMenuItem.subPositive:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(GetMessageTone(
                                          widget.textEditingController.text,
                                          'positive'));
                                  break;
                                case AISubToneMenuItem.subNegative:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(GetMessageTone(
                                          widget.textEditingController.text,
                                          'negative'));
                                  break;
                                case AISubToneMenuItem.subCringe:
                                  BlocProvider.of<AiMessageBloc>(rootContext)
                                      .add(GetMessageTone(
                                          widget.textEditingController.text,
                                          'cringe'));
                                  break;
                              }
                              submenuIsOpen = false;
                              iconData = Icons.arrow_drop_up_outlined;
                              Navigator.pop(context); //close main menu
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<AISubToneMenuItem>>[
                              PopupMenuItem<AISubToneMenuItem>(
                                value: AISubToneMenuItem.subPositive,
                                padding: EdgeInsets.only(left: subMenuPad),
                                child: const Text('positive'),
                              ),
                              PopupMenuItem<AISubToneMenuItem>(
                                value: AISubToneMenuItem.subNegative,
                                padding: EdgeInsets.only(left: subMenuPad),
                                child: const Text('negative'),
                              ),
                              PopupMenuItem<AISubToneMenuItem>(
                                value: AISubToneMenuItem.subCringe,
                                padding: EdgeInsets.only(left: subMenuPad),
                                child: const Text('cringe'),
                              ),
                            ],
                            child: ListTile(
                              enabled:
                                  widget.textEditingController.text.isNotEmpty,
                              horizontalTitleGap: 0,
                              title: const Align(
                                  alignment: AlignmentGeometry.center,
                                  child: Text('Change tone')),
                              trailing: Icon(iconData),
                            ),
                          );
                        }),
                      ),
                    ],
                child: const Padding(
                    padding: EdgeInsets.fromLTRB(2, 2, 6, 2),
                    child: Icon(Icons.auto_awesome_outlined, color: dullGray))),
          ),
        ));
  }

  double estimatedMenuHeight(int itemsLength) {
    // From MenuAnchor source: minimum height is 48.0
    const double itemHeight = 48.0;
    // From MenuAnchor source: menu vertical padding is 16.0
    const double menuPadding = 16.0;
    return itemsLength * itemHeight + menuPadding + 10;
  }
}
