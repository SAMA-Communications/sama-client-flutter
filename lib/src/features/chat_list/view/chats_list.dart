import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chats.dart';


class ChatsList extends StatefulWidget {
  const ChatsList({super.key});

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        switch (state.status) {
          case ChatStatus.failure:
            return const Center(child: Text('failed to fetch posts'));
          case ChatStatus.success:
            if (state.chats.isEmpty) {
              return const Center(child: Text('no chats'));
            }
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.chats.length
                    ? const BottomLoader()
                    : ChatListItem(chat: state.chats[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.chats.length
                  : state.chats.length + 1,
              controller: _scrollController,
              separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              )
            );
          case ChatStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ChatBloc>().add(ChatFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}