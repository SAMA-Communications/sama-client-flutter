import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sama_client_flutter/src/db/models/conversation.dart';
import 'package:sama_client_flutter/src/features/conversations_list/conversations.dart';

import '../../../api/api.dart';
import '../../../shared/ui/colors.dart';
import '../../conversations_list/widgets/avatar_group_icon.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../bloc/global_search_bloc.dart';
import '../bloc/global_search_event.dart';
import '../bloc/global_search_state.dart';
import '../models/search_result_item.dart';

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
    _textController.text = '';
    _globalSearchBloc.add(const TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const Text('Please enter a term to begin'),
          SearchStateLoading() => const CircularProgressIndicator.adaptive(),
          SearchStateError() => Text(state.error),
          SearchStateSuccess() =>
            state.users.isEmpty && state.conversations.isEmpty
                ? const Text('No Results')
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
    final conversationList = ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (BuildContext context, int index) {
        final conversation = conversations[index];
        return ConversationListItem(conversation: conversation);
      },
    );

    final userList = ListView.builder(
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final user = users[index];
        return ListTile(
          leading: AvatarLetterIcon(name: user.login!),
          title: Text(user.login!),
          onTap: () => print("onTap user $user"),
        );
      },
    );

    // final conversationList = ListView.builder(
    //   itemCount: conversations.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     final conversation = conversations[index];
    //     return ListTile(
    //       leading:const AvatarGroupIcon(),
    //       title: Text(conversation.name!),
    //       onTap: () => print("onTap conversation $conversation"),
    //     );
    //   },
    // );

    return Column(
      children: <Widget>[
        userList,
        conversationList,
      ],
    );
  }
}
