import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/repository/conversation/conversation_data_source.dart';
import 'src/repository/global_search/global_search_repository.dart';

import 'src/navigation/app_router.dart';
import 'src/repository/authentication/authentication_repository.dart';
import 'src/repository/conversation/conversation_repository.dart';
import 'src/repository/messages/messages_repository.dart';
import 'src/repository/user/user_repository.dart';
import 'src/shared/auth/bloc/auth_bloc.dart';
import 'src/shared/ui/colors.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
  late final GlobalSearchRepository _globalSearchRepository;
  late final ConversationLocalDataSource _conversationLocalDataSource;

  @override
  void initState() {
    super.initState();
    _conversationLocalDataSource = ConversationLocalDataSource();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _conversationRepository =
        ConversationRepository(localDataSource: _conversationLocalDataSource);
    _globalSearchRepository =
        GlobalSearchRepository(localDataSource: _conversationLocalDataSource);
    _messagesRepository = MessagesRepository(userRepository: _userRepository);
    _messagesRepository.initChatListeners();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    _messagesRepository.destroyChatListeners();
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
        RepositoryProvider<GlobalSearchRepository>(
          create: (context) => _globalSearchRepository,
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
