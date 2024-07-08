import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/conversations_list/view/conversations_page.dart';
import '../features/login/view/login_page.dart';
import '../features/search/view/search_page.dart';
import '../repository/authentication/authentication_repository.dart';
import '../shared/auth/bloc/auth_bloc.dart';
import 'constants.dart';

GoRouter router(BuildContext context) => GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: rootScreenPath,
          builder: (context, state) => const HomePage(),
          redirect: (context, state) {
            return BlocProvider.of<AuthenticationBloc>(context)
                .tryGetUser()
                .then((currentUser) {
              print('[router][$rootScreenPath] ${state.fullPath}');
              return currentUser != null ? state.fullPath : loginScreenPath;
            });
          },
        ),
        GoRoute(
            path: loginScreenPath,
            builder: (context, state) {
              return const LoginPage();
            }),
        GoRoute(
          path: conversationListScreenPath,
          builder: (context, state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: globalSearch,
          builder: (context, state) {
            return const SearchPage();
          },
        ),
      ],
      refreshListenable:
          GoRouterRefreshBloc<AuthenticationBloc, AuthenticationState>(
        BlocProvider.of<AuthenticationBloc>(context),
      ),
      redirect: (context, state) {
        return BlocProvider.of<AuthenticationBloc>(context)
            .tryGetUser()
            .then((currentUser) {
          print('[router][redirect] ${state.fullPath}');
          return currentUser != null
              ? state.fullPath == loginScreenPath
                  ? rootScreenPath
                  : state.fullPath
              : loginScreenPath;
        });
      },
    );

// The router Bloc that required to manage the user authorisation state at any app point.
// When authorisation state was changer the router will catch this event and redirect to the right screen
class GoRouterRefreshBloc<BLOC extends BlocBase<STATE>, STATE>
    extends ChangeNotifier {
  GoRouterRefreshBloc(BLOC bloc) {
    _blocStream = bloc.stream.listen(
      (STATE state) {
        print('[GoRouterRefreshBloc][listen] state: state');
        if (state is AuthenticationState) {
          var authenticationState = state as AuthenticationState;
          if (authenticationState.status ==
                  AuthenticationStatus.authenticated ||
              authenticationState.status ==
                  AuthenticationStatus.unauthenticated) {
            print('[GoRouterRefreshBloc][listen] notifyListeners');
            notifyListeners();
          }
        }
      },
    );
  }

  late final StreamSubscription<STATE> _blocStream;

  @override
  void dispose() {
    _blocStream.cancel();
    super.dispose();
  }
}
