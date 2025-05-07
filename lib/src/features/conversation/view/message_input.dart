import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../db/models/message_model.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import 'media_sender.dart';

class MessageInput extends StatefulWidget {
  final String? sharedText;
  final MessageModel? draftMessage;

  const MessageInput({super.key, this.sharedText, this.draftMessage});

  @override
  State<StatefulWidget> createState() {
    return _MessageInputState();
  }
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController textEditingController =
      TextEditingController(text: widget.sharedText);

  @override
  Widget build(BuildContext context) {
    if (widget.sharedText != null) {
      BlocProvider.of<SendMessageBloc>(context)
          .add(TextMessageChanged(widget.sharedText!));
    } else if (widget.draftMessage != null) {
      textEditingController.text = widget.draftMessage!.body!;
      BlocProvider.of<SendMessageBloc>(context)
          .add(TextMessageChanged(widget.draftMessage!.body!));
    }
    return BlocListener<SendMessageBloc, SendMessageState>(
      listener: (context, state) {
        if (state.status == SendMessageStatus.success) {
          textEditingController.clear();
        } else if (state.status == SendMessageStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                  content: Text('Can\'t send message due to some error(s)')),
            );
        }
      },
      child: BlocBuilder<SendMessageBloc, SendMessageState>(
        builder: (rootContext, state) {
          return Container(
            constraints: const BoxConstraints(maxHeight: 120.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                                            .currentConversation),
                                  ),
                                );
                              },
                            ));
                  },
                ),
                Flexible(
                  child: TextField(
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
          );
        },
      ),
    );
  }

  void onSendChatMessage(BuildContext context, String text) {
    BlocProvider.of<SendMessageBloc>(context).add(SendTextMessage(text));
    if (widget.draftMessage != null) {
      BlocProvider.of<ConversationBloc>(context)
          .add(const RemoveDraftMessage());
    }
  }
}
