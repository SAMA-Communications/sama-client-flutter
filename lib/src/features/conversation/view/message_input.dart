import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/send_message/send_message_bloc.dart';
import '../widgets/header_input_box.dart';
import 'media_sender.dart';

class MessageInput extends StatefulWidget {
  final String? sharedText;

  const MessageInput({super.key, this.sharedText});

  @override
  State<StatefulWidget> createState() {
    return _MessageInputState();
  }
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController textEditingController =
      TextEditingController(text: widget.sharedText);

  final FocusNode showFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var showReply = false;
    var showEdit = false;
    if (widget.sharedText != null) {
      BlocProvider.of<SendMessageBloc>(context)
          .add(TextMessageChanged(widget.sharedText!));
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
                widget.sharedText == null;
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
                      connectionChecker(
                          context,
                          () => showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 10.0),
                                    actionsPadding: EdgeInsets.zero,
                                    buttonPadding: EdgeInsets.zero,
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: MediaSender.create(
                                          currentConversation: rootContext
                                              .watch<SendMessageBloc>()
                                              .currentConversation,
                                          replyMessage: state.replyMessage),
                                    ),
                                  );
                                },
                              ));
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

  @override
  void dispose() {
    showFocusNode.dispose();
    super.dispose();
  }
}
