import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../db/models/conversation_model.dart';
import '../../../db/models/user_model.dart';
import '../../../shared/ui/colors.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_event.dart';
import '../../conversations_list/conversations_list.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';

enum SearchType {
  users,
  chats,
  both,
}

class SearchResults extends StatelessWidget {
  const SearchResults(this.users, this.conversations,
      {super.key, this.searchType = SearchType.both, this.chatOnTap});

  final List<UserModel>? users;
  final List<ConversationModel>? conversations;
  final SearchType searchType;
  final void Function(ConversationModel)? chatOnTap;

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

    final chatList = conversations == null
        ? null
        : conversations!.isEmpty
            ? _emptyListText('We couldn\'t find the specified chats')
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: conversations!.length,
                itemBuilder: (BuildContext context, int index) {
                  final chat = conversations![index];
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
            if (searchType == SearchType.both)
              if (chatList != null) ...[_header('Chats'), chatList],
          ],
        ],
      ),
    );
  }
}
