import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/conversation_model.dart';
import '../../../db/models/user_model.dart';
import '../../../features/search/view/search_bar.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_event.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';
import '../../conversations_list/conversations_list.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../bloc/global_search_bloc.dart';
import '../bloc/global_search_state.dart';

class SearchForm extends StatelessWidget {
  const SearchForm(
      {this.searchType = SearchType.both, this.chatOnTap, super.key});

  final SearchType searchType;
  final Function(ConversationModel)? chatOnTap;

  @override
  Widget build(BuildContext context) {
    // final LoadingOverlay loadingOverlay = LoadingOverlay();

    return BlocListener<ConversationCreateBloc, ConversationCreateState>(
      listener: (context, state) {
        if (state is ConversationCreatedLoading) {
          // loadingOverlay.show(context);// for now disable
        } else if (state is ConversationCreatedState) {
          // loadingOverlay.hide();// for now disable
          ConversationModel conversation = state.conversation;
          context.go('$conversationListScreenPath/$conversationScreenSubPath',
              extra: conversation);
        } else if (state is ConversationCreatedStateError) {
          // loadingOverlay.hide();// for now disable
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error ?? '')),
            );
        }
      },
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          return switch (state) {
            SearchStateEmpty() => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: Text('Please start typing to find user or chat'),
              ),
            SearchStateLoading() => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            SearchStateError() => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(state.error),
              ),
            SearchStateSuccess() => SearchResults(
                state.users, state.conversations,
                searchType: searchType, chatOnTap: chatOnTap),
          };
        },
      ),
    );
  }
}

enum SearchType {
  users,
  chats,
  both,
}

class SearchResults extends StatelessWidget {
  const SearchResults(this.users, this.conversations,
      {super.key, this.searchType = SearchType.both, this.chatOnTap});

  final List<UserModel>? users;
  final List<ConversationModel> conversations;
  final SearchType searchType;
  final void Function(ConversationModel)? chatOnTap;

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

    final conversationList = conversations.isEmpty
        ? _emptyListText('We couldn\'t find the specified chats')
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: conversations.length,
            itemBuilder: (BuildContext context, int index) {
              final chat = conversations[index];
              return ConversationListItem(
                  conversation: chat, onTap: () => chatOnTap?.call(chat));
            },
          );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        children: <Widget>[
          if (searchType == SearchType.both ||
              searchType == SearchType.users) ...[
            if (searchType == SearchType.both)
              if (userList != null) ...[_header('Users'), userList],
          ],
          if (searchType == SearchType.both ||
              searchType == SearchType.chats) ...[
            if (searchType == SearchType.both) _header('Chats'),
            conversationList,
          ],
        ],
      ),
    );
  }
}
