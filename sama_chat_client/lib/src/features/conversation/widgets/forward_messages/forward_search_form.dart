import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../db/models/models.dart';
import '../../../../navigation/constants.dart';
import '../../../../shared/ui/colors.dart';
import '../../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../../conversation_create/bloc/conversation_create_state.dart';
import '../../../search/bloc/global_search_bloc.dart';
import '../../../search/bloc/global_search_state.dart';
import '../../../search/view/search_bar.dart';
import '../../../search/view/search_form.dart';
import '../../bloc/conversation_bloc.dart';
import '../../bloc/forward_message/forward_messages_bloc.dart';
import '../../models/chat_message.dart';

class ForwardSearchForm extends StatelessWidget {
  final Set<ChatMessage> forwardMessages;

  const ForwardSearchForm(
    this.forwardMessages, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    double topPadding = window.viewPadding.top / window.devicePixelRatio -
        (Platform.isIOS ? 30 : 15);
    return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: black,
                automaticallyImplyLeading: false,
                centerTitle: true,
                toolbarHeight: kToolbarHeight + topPadding,
                title: Padding(
                    padding: EdgeInsets.only(top: topPadding + 5),
                    child: const Text(
                      'Forward message',
                      style: TextStyle(color: white),
                    ))),
            body: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  spacing: 4,
                  children: [
                    const GlobalSearchBar(),
                    _SearchBody(forwardMessages),
                  ],
                ))));
  }
}

class _SearchBody extends StatelessWidget {
  final Set<ChatMessage> forwardMessages;

  const _SearchBody(this.forwardMessages);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ForwardMessagesBloc, ForwardMessagesState>(
            listener: (context, state) {
          switch (state.status) {
            case ForwardMessagesStatus.initial:
              break;
            case ForwardMessagesStatus.processing:
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );
              break;
            case ForwardMessagesStatus.success:
              context
                  .read<ConversationBloc>()
                  .add(const SelectMessagesMode(false));
              Navigator.popUntil(context, (route) => route.isFirst);
              if (state.chatsTo.length == 1) {
                ConversationModel conversation = state.chatsTo.first;
                context.go(
                    '$conversationListScreenPath/$conversationScreenSubPath',
                    extra: conversation);
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Forwarded successfully')),
                );
            case ForwardMessagesStatus.failure:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(state.errorMessage ?? '')),
                  );
              });
          }
        }),
        BlocListener<ConversationCreateBloc, ConversationCreateState>(
          listener: (context, state) {
            if (state is ConversationCreatedState) {
              ConversationModel conversation = state.conversation;
              context
                  .read<ForwardMessagesBloc>()
                  .add(SendForwardMessage([conversation], forwardMessages));
            } else if (state is ConversationCreatedStateError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.error ?? '')),
                );
            }
          },
        )
      ],
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          var chats = context.watch<ForwardMessagesBloc>().state.chats;
          return switch (state) {
            SearchStateEmpty() => chats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text('Please start typing to find chat'),
                  )
                : Expanded(
                    child: SearchResults(null, chats, chatOnTap: (chat) {
                    context
                        .read<ForwardMessagesBloc>()
                        .add(SendForwardMessage([chat], forwardMessages));
                  })),
            SearchStateLoading() => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            SearchStateError() => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(state.error),
              ),
            SearchStateSuccess() => Expanded(
                  child: SearchResults(state.users, state.conversations,
                      chatOnTap: (chat) {
                context
                    .read<ForwardMessagesBloc>()
                    .add(SendForwardMessage([chat], forwardMessages));
              })),
          };
        },
      ),
    );
  }
}
