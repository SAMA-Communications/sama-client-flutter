import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../navigation/constants.dart';
import '../../../shared/utils/observer_utils.dart';
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
  void didPopNext() {
    // TODO RP for now not using
    // context.read<ConversationsBloc>().add(ConversationsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
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
            if (state.initial) {
              context.read<ConversationsBloc>().add(ConversationsFetched());
            }
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
                  return index >= state.conversations.length
                      ? const BottomLoader()
                      : ConversationListItem(
                          conversation: state.conversations[index]);
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
    if (_isBottom)
      context.read<ConversationsBloc>().add(ConversationsFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
