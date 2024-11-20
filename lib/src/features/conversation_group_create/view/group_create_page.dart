import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/conversation.dart';
import '../../../navigation/constants.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../../../shared/ui/view/loading_overlay.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';
import '../../search/bloc/global_search_bloc.dart';
import '../bloc/group_bloc.dart';
import 'group_create_form.dart';

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
    final LoadingOverlay loadingOverlay = LoadingOverlay();
    return BlocListener<ConversationCreateBloc, ConversationCreateState>(
        listener: (context, state) {
          if (state is ConversationCreatedLoading) {
            loadingOverlay.show(context);
          } else if (state is ConversationCreatedState) {
            loadingOverlay.hide();
            ConversationModel conversation = state.conversation;
            context.go('$conversationListScreenPath/$conversationScreenSubPath',
                extra: conversation);
          } else if (state is ConversationCreatedStateError) {
            loadingOverlay.hide();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? '')),
              );
          }
        },
        child: const GroupForm());
  }
}
