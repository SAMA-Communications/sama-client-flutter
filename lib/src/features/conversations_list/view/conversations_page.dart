import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../repository/authentication/authentication_repository.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/connection/bloc/connection_bloc.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../conversations_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static BlocProvider route() {
    return BlocProvider<ConversationsBloc>(
        create: (context) {
          final bloc = ConversationsBloc(
              conversationRepository:
                  RepositoryProvider.of<ConversationRepository>(context))
            ..add(const ConversationsFetched());
          if (context.read<ConnectionBloc>().state.status ==
              ConnectionStatus.connected) {
            bloc.add(const ConversationsFetched(force: true));
          }
          return bloc;
        },
        child: const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharingIntentBloc, SharingIntentState>(
        builder: (BuildContext context, state) {
      return Scaffold(
          appBar: state.status == SharingIntentStatus.processing
              ? const SelectChatAppBar() as PreferredSizeWidget
              : const ChatAppBar(),
          body: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state.status == AuthenticationStatus.authenticated) {
                    BlocProvider.of<ConversationsBloc>(context)
                        .add(const ConversationsFetched(force: true));
                  }
                },
              ),
              BlocListener<ConnectionBloc, ConnectionState>(
                listener: (context, state) {
                  if (state.status == ConnectionStatus.connected &&
                      context.read<AuthenticationBloc>().state.status ==
                          AuthenticationStatus.authenticated) {
                    BlocProvider.of<ConversationsBloc>(context)
                        .add(const ConversationsFetched(force: true));
                  }
                },
              ),
            ],
            child: const ConversationsList(),
          ),
          floatingActionButton: state.status == SharingIntentStatus.processing
              ? null
              : ConnectionChecker(
                  child: FloatingActionButton(
                    // fix error https://github.com/flutter/flutter/issues/115358
                    heroTag: null,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.add_comment_outlined, size: 32.0),
                    ),
                    onPressed: () {
                      context.push(groupCreateScreenPath);
                    },
                  ),
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
    return BlocBuilder<ConnectionBloc, ConnectionState>(
        builder: (BuildContext context, state) {
      return AppBar(
        backgroundColor: black,
        automaticallyImplyLeading: false,
        leading: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.person_outline,
                  color: lightWhite, size: 32.0),
              tooltip: 'Profile',
              onPressed: () {
                context.push(profilePath);
              },
            )),
        title: const Text(
          'Chat',
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        actions: <Widget>[
          ConnectionChecker(
            child: IconButton(
              onPressed: () => _openSearch(context),
              icon: const Icon(
                Icons.search,
                color: white,
                size: 32,
              ),
            ),
          ),
        ],
      );
    });
  }

  _openSearch(BuildContext context) {
    context.push(globalSearchPath);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
