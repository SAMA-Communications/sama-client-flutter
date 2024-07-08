import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sama_client_flutter/src/features/search/view/search_form.dart';

import '../../../repository/global_search/global_search_repository.dart';
import '../bloc/global_search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SearchPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => GlobalSearchBloc(
            globalSearchRepository:
                RepositoryProvider.of<GlobalSearchRepository>(context)),
        child: const SearchForm(),
      ),
    );
  }
}
