import 'package:go_router/go_router.dart';
import 'package:sama_client_flutter/src/navigation/screens/chat_lists_screen.dart';

import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: rootScreenPath,
      builder: (context, state) => const HomeScreen(),
      redirect: (context, state) {
        final loggedIn = false; // TODO VT test code
        return loggedIn ? chatListScreenPath : loginScreenPath;
      },
    ),
    GoRoute(
      path: loginScreenPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: chatListScreenPath,
      builder: (context, state) => const ChatListScreen(),
    ),
  ],
);
