import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../search/bloc/global_search_bloc.dart';
import '../../search/view/search_bar.dart';
import '../bloc/group_bloc.dart';
import 'group_form.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

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
        BlocProvider<GroupBloc>(
          create: (context) => GroupBloc(),
        ),
      ],
      child: const GroupPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: const GlobalSearchBar(),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
          child: const GroupNameForm()),
      floatingActionButton: Visibility(
        visible: !keyboardIsOpen,
        child: FloatingActionButton(
          backgroundColor: whiteAluminum,
          tooltip: 'Create chat',
          onPressed: () {
            context.read<GroupBloc>().add(GroupSubmitted());
          },
          child: const Icon(Icons.check, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
