import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../conversations_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharingIntentBloc, SharingIntentState>(
        builder: (BuildContext context, state) {
      return Scaffold(
        appBar: state.status == SharingIntentStatus.processing
            ? const SelectChatAppBar() as PreferredSizeWidget
            : const ChatAppBar(),
        body: BlocProvider(
          create: (context) {
            return ConversationsBloc(
                conversationRepository:
                    RepositoryProvider.of<ConversationRepository>(context))
              ..add(ConversationsFetched());
          },
          child: const ConversationsList(),
        ),
        floatingActionButton: state.status == SharingIntentStatus.processing
            ? null
            : FloatingActionButton(
                // fix error https://github.com/flutter/flutter/issues/115358
                heroTag: null,
                child: const Icon(Icons.add_comment_outlined, size: 32.0),
                onPressed: () {
                  context.push(groupCreateScreenPath);
                },
              ),
      );
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
            icon:
                const Icon(Icons.person_outline, color: lightWhite, size: 32.0),
            tooltip: 'Profile',
            onPressed: () {
              context.push(profilePath);
            },
          )),
      title: const Text(
        "Chat",
        style: TextStyle(color: white),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => _openSearch(context),
          icon: const Icon(
            Icons.search,
            color: white,
            size: 32,
          ),
        ),
      ],
    );
  }

  _openSearch(BuildContext context) {
    context.push(globalSearchPath);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
