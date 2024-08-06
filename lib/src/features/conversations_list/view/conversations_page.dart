import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../conversations_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/vector_logo.png',
            width: 32,
            fit: BoxFit.cover,
          ),
          tooltip: 'Logout',
          onPressed: () {
            context
                .read<AuthenticationBloc>()
                .add(AuthenticationLogoutRequested());
          },
        ),
        title: const Text(
          'Chat',
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
      ),
      body: BlocProvider(
        create: (context) {
          return ConversationBloc(
              conversationRepository:
                  RepositoryProvider.of<ConversationRepository>(context))
            ..add(ConversationFetched());
        },
        child: const ConversationsList(),
      ),
    );
  }

  _openSearch(BuildContext context) {
    context.push(globalSearchPath);
  }
}
