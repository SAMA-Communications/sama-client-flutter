import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../global_search/bloc/global_search_bloc.dart';
import '../bloc/search_bloc.dart';
import 'search_form.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static MultiBlocProvider route() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GlobalSearchBloc>(
          create: (context) => GlobalSearchBloc(
            globalSearchRepository:
                RepositoryProvider.of<GlobalSearchRepository>(context),
          ),
        ),
        BlocProvider<ConversationCreateBloc>(
          create: (context) => ConversationCreateBloc(
            conversationRepository:
                RepositoryProvider.of<ConversationRepository>(context),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
              RepositoryProvider.of<ConversationRepository>(context),
              RepositoryProvider.of<UserRepository>(context)),
        ),
      ],
      child: const SearchPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SearchForm();
  }
}
