import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../db/models/models.dart';
import '../../../../navigation/constants.dart';
import '../../../../shared/ui/colors.dart';
import '../../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../../conversation_create/bloc/conversation_create_event.dart';
import '../../../conversation_create/bloc/conversation_create_state.dart';
import '../../../conversations_list/conversations_list.dart';
import '../../../conversations_list/widgets/avatar_letter_icon.dart';
import '../../../search/bloc/global_search_bloc.dart';
import '../../../search/bloc/global_search_state.dart';
import '../../../search/view/search_bar.dart';
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
    return Column(
      children: <Widget>[
        const GlobalSearchBar(withBack: false),
        _SearchBody(forwardMessages),
      ],
    );
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
              context.read<ConversationBloc>().add(const ChooseMessages(false));
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
                : Expanded(child: _SearchResults(null, chats, forwardMessages)),
            SearchStateLoading() => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            SearchStateError() => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(state.error),
              ),
            SearchStateSuccess() => Expanded(
                child: _SearchResults(
                    state.users, state.conversations, forwardMessages)),
          };
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<UserModel>? users;
  final List<ConversationModel> chats;
  final Set<ChatMessage> forwardMessages;

  const _SearchResults(this.users, this.chats, this.forwardMessages);

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.only(left: 18.0),
        width: double.maxFinite,
        color: gainsborough, //define the background color
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _emptyListText(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userList = users == null
        ? null
        : users!.isEmpty
            ? _emptyListText('We couldn\'t find the specified users')
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: users!.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = users![index];
                  return ListTile(
                    leading: AvatarLetterIcon(
                        name: user.login!, avatar: user.avatar),
                    title: Text(
                      user.login!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding:
                        const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
                    onTap: () {
                      context
                          .read<ConversationCreateBloc>()
                          .add(ConversationCreated(user: user, type: 'u'));
                    },
                  );
                },
              );

    final conversationList = chats.isEmpty
        ? _emptyListText('We couldn\'t find the specified chats')
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: chats.length,
            itemBuilder: (BuildContext context, int index) {
              final conversation = chats[index];
              return ConversationListItem(
                conversation: conversation,
                onTap: () {
                  context
                      .read<ForwardMessagesBloc>()
                      .add(SendForwardMessage([conversation], forwardMessages));
                },
              );
            },
          );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        children: <Widget>[
          if (userList != null) ...[_header('Users'), userList],
          _header('Chats'),
          conversationList,
        ],
      ),
    );
  }
}
