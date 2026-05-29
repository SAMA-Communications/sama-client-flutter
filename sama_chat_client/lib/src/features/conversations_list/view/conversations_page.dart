import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/connection/bloc/connection_bloc.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/connection/view/connection_title.dart';
import '../../../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../../conversation_delete/bloc/conversation_delete_bloc.dart';
import '../conversations_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static MultiBlocProvider route() {
    return MultiBlocProvider(providers: [
      BlocProvider<ConversationsBloc>(create: (context) {
        final bloc = ConversationsBloc(
            conversationRepository:
                RepositoryProvider.of<ConversationRepository>(context))
          ..add(const ConversationsFetched());
        if (context.read<ConnectionBloc>().state.status ==
            ConnectionStatus.connected) {
          bloc.add(const ConversationsFetched(refresh: true));
        }
        return bloc;
      }),
      BlocProvider<ConversationDeleteBloc>(
          create: (context) => ConversationDeleteBloc(
                conversationRepository:
                    RepositoryProvider.of<ConversationRepository>(context),
              )),
    ], child: const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharingIntentBloc, SharingIntentState>(
        builder: (BuildContext context, state) {
      return Scaffold(
          appBar: state.status == SharingIntentStatus.processing
              ? const SelectChatAppBar() as PreferredSizeWidget
              : const ChatAppBar(),
          body: BlocListener<ConnectionBloc, ConnectionState>(
            listener: (context, state) {
              if (state.status == ConnectionStatus.connected) {
                BlocProvider.of<ConversationsBloc>(context)
                    .add(const ConversationsFetched(refresh: true));
              }
            },
            child: const ConversationsList(),
          ));
    });
  }
}

class SelectChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SelectChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: lightWhite, size: 30.0),
        tooltip: 'Cancel',
        onPressed: () {
          context.read<SharingIntentBloc>().add(SharingIntentCompleted());
        },
      ),
      title: const Text(
        "Select Chat",
        style: TextStyle(color: white),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      automaticallyImplyLeading: false,
      leading: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                color: lightWhite, size: 32.0),
            tooltip: 'Profile',
            onPressed: () {
              context.push(profilePath);
            },
          )),
      title: const ConnectionTitle(
          color: white, title: Text('Chat', style: TextStyle(color: white))),
      centerTitle: true,
      actions: <Widget>[
        ConnectionChecker(
          child: IconButton(
            onPressed: () => context.push(searchScreenPath),
            icon: const Icon(
              Icons.edit_note_outlined,
              color: lightWhite,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
