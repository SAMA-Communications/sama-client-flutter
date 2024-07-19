import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../conversations_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/vector_logo.png',
            width: 32,
            fit: BoxFit.cover,
          ),
          onPressed: () {},
        ),
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _openSearch(context),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
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

  _openSearch(BuildContext context) {}
}
