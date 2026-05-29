import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../db/models/conversation_model.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/observer_utils.dart';
import '../../../shared/widget/swipe_to.dart';
import '../../conversation_delete/bloc/conversation_delete_bloc.dart';
import '../conversations_list.dart';

class ConversationsList extends StatefulWidget {
  const ConversationsList({super.key});

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> with RouteAware {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationDeleteBloc, ConversationDeleteState>(
        listener: (context, state) {
      switch (state.status) {
        case ConversationDeleteStatus.initial:
        case ConversationDeleteStatus.success:
          break;
        case ConversationDeleteStatus.failure:
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text(state.errorMessage ?? '')),
            );
      }
    }, child: BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        switch (state.status) {
          case ConversationsStatus.failure:
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: const Text(
                'The chats are unavailable. Please check your Internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          case ConversationsStatus.success:
            if (state.conversations.isEmpty) {
              return state.initial
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: const Text(
                          'No conversations yet...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
            }
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  var chat = state.conversations[index];
                  var typing = state.typingStatuses[chat.id];
                  return index >= state.conversations.length
                      ? const BottomLoader()
                      : buildChat(chat, typing);
                },
                itemCount: state.conversations.length,
                // itemCount: state.hasReachedMax
                //     ? state.conversations.length
                //     : state.conversations.length + 1,
                controller: _scrollController,
                separatorBuilder: (context, index) => const SizedBox(
                      height: 5,
                    ));
          case ConversationsStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }

  Widget buildChat(ConversationModel chat, TypingChatStatus? typing) {
    return SwipeTo(
      key: Key(chat.id.toString()),
      stickToRight: true,
      direction: DismissDirection.endToStart,
      onSwipe: () {
        print('onSwipe');
        connectionChecker(
            context,
            () => showModalBottomSheet(
                  context: context,
                  builder: (BuildContext bc) {
                    return SafeArea(
                        child: SizedBox(
                      height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: TextButton(
                                style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  context
                                      .read<ConversationDeleteBloc>()
                                      .add(ConversationDeleted(chat: chat));
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete for all'),
                              )),
                        ],
                      ),
                    ));
                  },
                ));
      },
      actionIcon: const Icon(
        Icons.delete_forever_outlined,
        color: black,
        size: 25,
      ),
      child: ConversationListItem(conversation: chat, typingStatus: typing),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ConversationsBloc>().add(ConversationsMoreFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
