import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/navigation/app_router.dart';
import 'src/repository/authentication/authentication_repository.dart';
import 'src/repository/chat/chat_repository.dart';
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
  late final ChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _chatRepository = ChatRepository();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => _authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: _authenticationRepository,
          userRepository: _userRepository,
        ),
        child: RepositoryProvider(
          create: (context) => _chatRepository,
          child: const AppView(),
        ),
      ),
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
