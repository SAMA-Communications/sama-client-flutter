import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sama_client_flutter/src/db/models/conversation.dart';
import 'package:sama_client_flutter/src/features/conversations_list/conversations.dart';

import '../../../api/api.dart';
import '../../../shared/ui/colors.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../bloc/global_search_bloc.dart';
import '../bloc/global_search_event.dart';
import '../bloc/global_search_state.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(),
        _SearchBody(),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  late GlobalSearchBloc _globalSearchBloc;

  @override
  void initState() {
    super.initState();
    _globalSearchBloc = context.read<GlobalSearchBloc>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      // titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(
          'assets/images/vector_logo.png',
          width: 32,
          fit: BoxFit.cover,
        ),
        onPressed: () {},
      ),
      title: SizedBox(
        height: kToolbarHeight - 18,
        child: TextField(
          controller: _textController,
          autocorrect: false,
          onChanged: (text) {
            if (text.length >= 2) {
              _globalSearchBloc.add(
                TextChanged(text: text),
              );
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: white,
            contentPadding: const EdgeInsets.only(top: 14.0),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: GestureDetector(
              onTap: _onClearTapped,
              child: const Icon(Icons.clear),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: 'Search',
          ),
        ),
      ),
      centerTitle: false,
    );
  }

  void _onClearTapped() {
    if (_textController.text.isNotEmpty) {
      _textController.text = '';
      _globalSearchBloc.add(const TextChanged(text: ''));
    } else {
      context.pop();
    }
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: Text('Please enter a term to begin'),
            ),
          SearchStateLoading() => const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: CircularProgressIndicator.adaptive(),
            ),
          SearchStateError() => Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(state.error),
            ),
          SearchStateSuccess() =>
            state.users.isEmpty && state.conversations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text('No Results'),
                  )
                : Expanded(
                    child: _SearchResults(
                        users: state.users,
                        conversations: state.conversations)),
        };
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.users, required this.conversations});

  final List<User> users;
  final List<ConversationModel> conversations;

  @override
  Widget build(BuildContext context) {
    final userList = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: users.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // return the header
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.only(left: 18.0),
              width: double.maxFinite,
              color: gainsborough, //define the background color
              child: const Text(
                'Users',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
        index -= 1;

        final user = users[index];
        return ListTile(
          leading: AvatarLetterIcon(name: user.login!),
          title: Text(
            user.login!,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
          onTap: () {
            print('onUser Clicked');
          },
        );
      },
    );

    final conversationList = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: conversations.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // return the header
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.only(left: 18.0),
              width: double.maxFinite,
              color: gainsborough, //define the background color
              child: const Text(
                'Chats',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
        index -= 1;
        final conversation = conversations[index];
        return ConversationListItem(
            conversation: conversation, onTap: onTapConversation);
      },
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 18.0),
        children: <Widget>[
          userList,
          conversationList,
        ],
      ),
    );
  }

  void onTapConversation() {
    print('onTapConversation Clicked');
  }
}
