import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/conversation.dart';
import '../../../navigation/constants.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';
import '../conversations_list.dart';
import '../../../shared/utils/observer_utils.dart';

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
    // context.read<ConversationsBloc>().add(ConversationsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationCreateBloc, ConversationCreateState>(
      listener: (context, state) {
        if (state is ConversationCreatedLoading) {
        } else if (state is ConversationCreatedState) {
          ConversationModel conversation = state.conversation;
          context.go('$conversationListScreenPath/$conversationScreenSubPath',
              extra: conversation);
        } else if (state is ConversationCreatedStateError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error ?? '')),
            );
        }
      },
      child: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          switch (state.status) {
            case ConversationsStatus.failure:
              return const Center(child: Text('failed to fetch conversations'));
            case ConversationsStatus.success:
              if (state.conversations.isEmpty) {
                return const Center(child: Text('no conversations'));
              }
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    child: const Icon(Icons.add_comment_outlined, size: 30.0),
                    onPressed: () {
                      context.push(groupCreateScreenPath);
                    },
                  ),
                  body: ListView.separated(
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
                      )));
            case ConversationsStatus.initial:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
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
