import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/conversation_group_create/view/group_page.dart';
import '../features/conversations_list/view/conversations_page.dart';
import '../features/conversation/view/conversation_page.dart';
import '../features/login/view/login_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/search/view/search_page.dart';
import '../features/splash_page.dart';
import '../features/user_info/view/user_info_page.dart';
import '../repository/authentication/authentication_repository.dart';
import '../shared/auth/bloc/auth_bloc.dart';
import '../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../shared/utils/observer_utils.dart';
import 'constants.dart';

GoRouter router(BuildContext context) => GoRouter(
      observers: [routeObserver],
      routes: <RouteBase>[
        GoRoute(
          path: rootScreenPath,
          builder: (context, state) => const HomePage(),
          redirect: (context, state) {
            final status = context.read<AuthenticationBloc>().state.status;
            print(
                'status = $status [router][$rootScreenPath] ${state.fullPath}');
            return status == AuthenticationStatus.authenticated
                ? state.fullPath
                : loginScreenPath;
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
          routes: [
            GoRoute(
              path: conversationScreenSubPath,
              builder: (context, state) {
                return ConversationPage.route(state.extra);
              },
            )
          ],
        ),
        GoRoute(
          path: splashScreenPath,
          builder: (context, state) {
            return const SplashPage();
          },
        ),
        GoRoute(
          path: globalSearchPath,
          builder: (context, state) {
            return SearchPage.route();
          },
        ),
        GoRoute(
          path: groupCreateScreenPath,
          builder: (context, state) {
            return GroupPage.route();
          },
        ),
        GoRoute(
          path: profilePath,
          builder: (context, state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: userInfoPath,
          builder: (context, state) {
            return UserInfoPage.route(state.extra);
          },
        ),
      ],
      refreshListenable: GoRouterRefreshBloc(
        BlocProvider.of<AuthenticationBloc>(context),
        BlocProvider.of<SharingIntentBloc>(context),
      ),
      redirect: (context, state) {
        final status = context.read<AuthenticationBloc>().state.status;
        print(
            'refreshListenable status = $status [router][redirect] ${state.fullPath}');

        if (context.read<SharingIntentBloc>().state.status ==
                SharingIntentStatus.sharing &&
            status == AuthenticationStatus.authenticated) {
          print('refreshListenable status sharing');
          context.read<SharingIntentBloc>().add(SharingIntentProcessing());
          return rootScreenPath;
        }

        if (status == AuthenticationStatus.authenticated) {
          return state.fullPath == loginScreenPath ||
                  state.fullPath == splashScreenPath
              ? rootScreenPath
              : state.fullPath;
        } else {
          return BlocProvider.of<AuthenticationBloc>(context)
              .tryGetHasLocalUser()
              .then((hasUser) {
            return hasUser ? splashScreenPath : loginScreenPath;
          });
        }
      },
    );

// The router Bloc that required to manage the user authorisation state and sharing feature at any app point.
// When authorisation state was changer the router will catch this event and redirect to the right screen
class GoRouterRefreshBloc extends ChangeNotifier {
  GoRouterRefreshBloc(
      AuthenticationBloc authBloc, SharingIntentBloc sharedBloc) {
    _blocStream = authBloc.stream.listen(
      (AuthenticationState authenticationState) {
        print('[GoRouterRefreshBloc][listen] state: $authenticationState');
        if (authenticationState.status == AuthenticationStatus.authenticated ||
            authenticationState.status ==
                AuthenticationStatus.unauthenticated) {
          print('[GoRouterRefreshBloc][listen] notifyListeners');
          notifyListeners();
        }
      },
    );
    _sharedBloc = sharedBloc.stream.listen(
      (SharingIntentState state) {
        if (state.status == SharingIntentStatus.sharing) {
          print('[GoRouterRefreshBloc][listen] sharing state: $state');
          notifyListeners();
        }
      },
    );
  }

  late final StreamSubscription<AuthenticationState> _blocStream;
  late final StreamSubscription<SharingIntentState> _sharedBloc;

  @override
  void dispose() {
    _blocStream.cancel();
    _sharedBloc.cancel();
    super.dispose();
  }
}
