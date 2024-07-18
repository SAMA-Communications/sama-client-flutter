import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/search/view/search_form.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../bloc/global_search_bloc.dart';

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
      ],
      child: const SearchPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SearchForm());
  }
}
