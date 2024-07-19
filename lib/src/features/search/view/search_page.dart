import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/search/view/search_form.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../bloc/global_search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static BlocProvider<GlobalSearchBloc> route() {
    return BlocProvider(
      create: (context) => GlobalSearchBloc(
        globalSearchRepository:
            RepositoryProvider.of<GlobalSearchRepository>(context),
      ),
      child: const SearchPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SearchForm());
  }
}
