import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/api_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/delete_messages/delete_messages_bloc.dart';
import 'forward_messages/forward_messages_widget.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectInputState();
  }
}

class _SelectInputState extends State<SelectInput> {
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
                      : () => connectionChecker(
                          context,
                          () => showModalBottomSheet(
                                context: context,
                                builder: (BuildContext bc) {
                                  return SizedBox(
                                    height: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        BlocProvider.value(
                                            value: BlocProvider.of<
                                                DeleteMessagesBloc>(context),
                                            child: TextButton(
                                              style: const ButtonStyle(
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DeleteMessagesBloc>()
                                                    .add(DeleteMessages(
                                                        state.selectedMessages
                                                            .value,
                                                        DeleteMessageType.all));
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  const Text('Delete for All'),
                                            )),
                                        const Divider(height: 1),
                                        BlocProvider.value(
                                            value: BlocProvider.of<
                                                DeleteMessagesBloc>(context),
                                            child: TextButton(
                                              style: const ButtonStyle(
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<DeleteMessagesBloc>()
                                                    .add(DeleteMessages(
                                                        state.selectedMessages
                                                            .value,
                                                        DeleteMessageType
                                                            .myself));
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  const Text('Delete for Me'),
                                            )),
                                      ],
                                    ),
                                  );
                                },
                              )),
                  color: dullGray,
                ),
                Text(
                    '${state.selectedMessages.value.length} of $maxChatsSelected selected',
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
