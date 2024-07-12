import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/navigation/app_router.dart';
import 'src/repository/authentication/authentication_repository.dart';
import 'src/repository/conversation/conversation_repository.dart';
import 'src/repository/messages/messages_repository.dart';
import 'src/repository/user/user_repository.dart';
import 'src/shared/auth/bloc/auth_bloc.dart';
import 'src/shared/ui/colors.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final ConversationRepository _conversationRepository;
  late final MessagesRepository _messagesRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _conversationRepository = ConversationRepository();
    _messagesRepository = MessagesRepository();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
          create: (context) => _authenticationRepository,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => _userRepository,
        ),
        RepositoryProvider<ConversationRepository>(
          create: (context) => _conversationRepository,
        ),
        RepositoryProvider<MessagesRepository>(
          create: (context) => _messagesRepository,
        ),
      ],
      child: BlocProvider(
          create: (_) => AuthenticationBloc(
                authenticationRepository: _authenticationRepository,
                userRepository: _userRepository,
              ),
          child: const AppView()),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router(context),
      title: 'SAMA client Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: slateBlue),
        useMaterial3: true,
      ),
    );
  }
}
