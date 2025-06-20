import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sama_firebase_options.dart';
import 'src/api/api.dart';
import 'src/db/db_service.dart';
import 'src/db/local/attachment_local_datasource.dart';
import 'src/db/local/conversation_local_datasource.dart';
import 'src/db/local/message_local_datasource.dart';
import 'src/db/local/user_local_datasource.dart';
import 'src/navigation/app_router.dart';
import 'src/repository/attachments/attachments_repository.dart';
import 'src/repository/authentication/authentication_repository.dart';
import 'src/repository/conversation/conversation_repository.dart';
import 'src/repository/global_search/global_search_repository.dart';
import 'src/repository/messages/messages_repository.dart';
import 'src/repository/user/user_repository.dart';
import 'src/shared/auth/bloc/auth_bloc.dart';
import 'src/shared/connection/bloc/connection_bloc.dart';
import 'src/shared/messages_collector/messages_collector.dart';
import 'src/shared/push_notifications/bloc/push_notifications_bloc.dart';
import 'src/shared/secure_storage.dart';
import 'src/shared/sharing/bloc/sharing_intent_bloc.dart';
import 'src/shared/ui/colors.dart';

//delete if no need
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: await SamaFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  DatabaseService.instance.init();
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
  late final ConversationLocalDatasource _conversationLocalDatasource;
  late final MessageLocalDatasource _messageLocalDatasource;
  late final AttachmentsRepository _attachmentsRepository;
  late final UserLocalDatasource _userLocalDatasource;
  late final AttachmentLocalDatasource _attachmentLocalDatasource;

  @override
  void initState() {
    super.initState();
    clearKeychainValuesIfUninstall();
    _conversationLocalDatasource = ConversationLocalDatasource();
    _messageLocalDatasource = MessageLocalDatasource();
    _userLocalDatasource = UserLocalDatasource();
    _attachmentLocalDatasource = AttachmentLocalDatasource();
    _userRepository = UserRepository(localDatasource: _userLocalDatasource);
    _authenticationRepository = AuthenticationRepository(_userRepository);
    _messagesRepository = MessagesRepository(
        localDatasource: _messageLocalDatasource,
        userRepository: _userRepository);
    _attachmentsRepository = AttachmentsRepository(_attachmentLocalDatasource);
    _conversationRepository = ConversationRepository(
        localDatasource: _conversationLocalDatasource,
        userRepository: _userRepository,
        messagesRepository: _messagesRepository);
    _globalSearchRepository = GlobalSearchRepository(
        conversationRepository: _conversationRepository,
        userRepository: _userRepository);
    MessagesCollector.instance
        .init(_conversationRepository, _messagesRepository);
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    _messagesRepository.dispose();
    _conversationRepository.dispose();
    _userRepository.dispose();
    MessagesCollector.instance.destroy();
    DatabaseService.instance.close();
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
              authenticationRepository: _authenticationRepository),
        ),
        BlocProvider(
            create: (context) => ConnectionBloc(
                authenticationRepository: _authenticationRepository),
            lazy: false),
        BlocProvider(create: (context) => SharingIntentBloc()),
        BlocProvider(
            create: (context) => PushNotificationsBloc(
                conversationRepository: _conversationRepository)),
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
      routerConfig: router(context, navigatorKey),
      title: 'SAMA client Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: slateBlue),
        useMaterial3: true,
      ),
    );
  }
}
