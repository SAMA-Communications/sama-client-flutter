import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/conversation.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_event.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';
import '../../../shared/ui/view/loading_overlay.dart';
import '../../conversations_list/conversations.dart';
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
    final LoadingOverlay loadingOverlay = LoadingOverlay();

    return BlocListener<ConversationCreateBloc, ConversationCreateState>(
      listener: (context, state) {
        if (state is ConversationCreatedLoading) {
          loadingOverlay.show(context);
        } else if (state is ConversationCreatedState) {
          loadingOverlay.hide();
          ConversationModel conversation = state.conversation;
          context.pop();
        } else if (state is ConversationCreatedStateError) {
          loadingOverlay.hide();
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
            SearchStateSuccess() => Expanded(
                child: _SearchResults(
                    users: state.users, conversations: state.conversations)),
          };
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.users, required this.conversations});

  final List<User> users;
  final List<ConversationModel> conversations;

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
    final userList = users.isEmpty
        ? _emptyListText('We couldn\'t find the specified users')
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              return ListTile(
                leading: AvatarLetterIcon(name: user.login!),
                title: Text(
                  user.login!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
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
              final conversation = conversations[index];
              return ConversationListItem(conversation: conversation);
            },
          );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        children: <Widget>[
          _header('Users'),
          userList,
          _header('Chats'),
          conversationList,
        ],
      ),
    );
  }
}
