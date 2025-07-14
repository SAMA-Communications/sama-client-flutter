import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/connection/view/connection_checker.dart';
import '../../../../shared/ui/colors.dart';
import '../../../../shared/utils/api_utils.dart';
import '../../bloc/conversation_bloc.dart';
import 'forward_messages_widget.dart';

class ForwardInput extends StatefulWidget {
  const ForwardInput({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForwardInputState();
  }
}

class _ForwardInputState extends State<ForwardInput> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 120.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: state.selectedMessages.value.isEmpty
                      ? null
                      : () => print('delete messages'),
                  color: dullGray,
                ),
                Text(
                    '${state.selectedMessages.value.length} of $maxChatsForwardTo selected',
                    style: const TextStyle(fontSize: 15)),
                IconButton(
                  icon: const Icon(Icons.forward_outlined),
                  color: dullGray,
                  onPressed: state.selectedMessages.value.isEmpty
                      ? null
                      : () {
                          connectionChecker(
                              context,
                              () => showModalBottomSheet<dynamic>(
                                  isScrollControlled: true,
                                  useSafeArea: false,
                                  context: context,
                                  builder: (BuildContext bc) {
                                    return Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQueryData.fromView(
                                                    View.of(context))
                                                .padding
                                                .top),
                                        child: BlocProvider.value(
                                          value:
                                              BlocProvider.of<ConversationBloc>(
                                                  context),
                                          child: ForwardMessagesWidget(
                                              state.selectedMessages.value),
                                        ));
                                  }));
                        },
                ),
              ],
            ),
          )
        ]);
      },
    );
  }
}
