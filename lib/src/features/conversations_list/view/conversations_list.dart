import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // ToDo RP for now not using
    // context.read<ConversationBloc>().add(ConversationRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        switch (state.status) {
          case ConversationStatus.failure:
            return const Center(child: Text('failed to fetch conversations'));
          case ConversationStatus.success:
            if (state.conversations.isEmpty) {
              return const Center(child: Text('no conversations'));
            }
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.conversations.length
                      ? const BottomLoader()
                      : ConversationListItem(
                          conversation: state.conversations[index]);
                },
                itemCount: state.hasReachedMax
                    ? state.conversations.length
                    : state.conversations.length + 1,
                controller: _scrollController,
                separatorBuilder: (context, index) => const SizedBox(
                      height: 5,
                    ));
          case ConversationStatus.initial:
            return const CenterLoader();
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
    if (_isBottom) context.read<ConversationBloc>().add(ConversationFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
