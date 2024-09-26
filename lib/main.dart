import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/navigation/app_router.dart';
import 'src/repository/attachments/attachments_repository.dart';
import 'src/repository/authentication/authentication_repository.dart';
import 'src/repository/conversation/conversation_data_source.dart';
import 'src/repository/conversation/conversation_repository.dart';
import 'src/repository/global_search/global_search_repository.dart';
import 'src/repository/messages/messages_repository.dart';
import 'src/repository/user/user_data_source.dart';
import 'src/repository/user/user_repository.dart';
import 'src/shared/auth/bloc/auth_bloc.dart';
import 'src/shared/sharing/bloc/sharing_intent_bloc.dart';
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
  late final GlobalSearchRepository _globalSearchRepository;
  late final ConversationLocalDataSource _conversationLocalDataSource;
  late final AttachmentsRepository _attachmentsRepository;
  late final UserLocalDataSource _userLocalDataSource;

  @override
  void initState() {
    super.initState();
    _conversationLocalDataSource = ConversationLocalDataSource();
    _userLocalDataSource = UserLocalDataSource();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository(localDataSource: _userLocalDataSource);
    _messagesRepository = MessagesRepository(userRepository: _userRepository);
    _attachmentsRepository = AttachmentsRepository();
    _conversationRepository = ConversationRepository(
        localDataSource: _conversationLocalDataSource,
        userRepository: _userRepository,
        messagesRepository: _messagesRepository);
    _globalSearchRepository =
        GlobalSearchRepository(localDataSource: _conversationLocalDataSource);
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    _messagesRepository.dispose();
    _conversationRepository.dispose();
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
        RepositoryProvider<AttachmentsRepository>(
          create: (context) => _attachmentsRepository,
        ),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository,
          ),
        ),
        BlocProvider(create: (context) => SharingIntentBloc()),
      ], child: const AppView()),
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
