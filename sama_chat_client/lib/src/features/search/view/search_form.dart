import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../db/models/models.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../global_search/bloc/global_search_bloc.dart';
import '../../global_search/bloc/global_search_state.dart';
import '../../global_search/view/search_bar.dart';
import '../../global_search/view/search_result.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';
import '../bloc/search_bloc.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return SearchFormState();
  }
}

class SearchFormState extends State<SearchForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: black,
          iconTheme: const IconThemeData(
            color: white,
          ),
          title: const Text(
            'New chat',
            style: TextStyle(color: white),
          ),
          centerTitle: true,
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlobalSearchBar(hintText: 'Search name or user'),
                  Row(children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                        child: TextButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(slateBlue),
                          ),
                          onPressed: () => context.push(groupCreateScreenPath),
                          icon: const Icon(Icons.group_outlined,
                              color: lightWhite, size: 25),
                          label: const Text(
                            'New group',
                            style: TextStyle(
                                color: lightWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  Expanded(
                      child: Align(
                          alignment: AlignmentGeometry.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, state) => UserChatForm(
                                  searchType: SearchType.both,
                                  users: state.users,
                                  chatOnTap: (chat) {
                                    context.go(
                                        '$conversationListScreenPath/$conversationScreenSubPath',
                                        extra: chat);
                                  }),
                            ),
                          )))
                ])));
  }
}

class UserChatForm extends StatelessWidget {
  const UserChatForm(
      {this.searchType = SearchType.both,
      this.chatOnTap,
      this.users,
      super.key});

  final SearchType searchType;
  final Function(ConversationModel)? chatOnTap;
  final List<UserModel>? users;

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
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          return switch (state) {
            SearchStateEmpty() => users?.isEmpty ?? true
                ? const Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text('Please start typing to find user or chat'),
                  )
                : SearchResults(users, null,
                    searchType: searchType, chatOnTap: chatOnTap),
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
