import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui/colors.dart';
import '../bloc/send_message/send_message_bloc.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
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
        builder: (context, state) {
          return Container(
            constraints: const BoxConstraints(maxHeight: 120.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            padding: const EdgeInsets.only(left: 8.0, right: 0.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: gainsborough,
            ),
            child: Row(
              children: [
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
                      BlocProvider.of<SendMessageBloc>(context)
                          .add(TextMessageChanged(text));
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: state.isTextEmpty
                      ? null
                      : () => onSendChatMessage(
                          context, textEditingController.text),
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
  }
}
