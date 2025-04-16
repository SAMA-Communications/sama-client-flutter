import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/group_info/view/group_info_page.dart';
import '../features/conversation_group_create/view/group_create_page.dart';
import '../features/conversations_list/view/conversations_page.dart';
import '../features/conversation/view/conversation_page.dart';
import '../features/login/view/login_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/search/view/search_page.dart';
import '../features/splash_page.dart';
import '../features/user_info/view/user_info_page.dart';
import '../repository/authentication/authentication_repository.dart';
import '../shared/auth/bloc/auth_bloc.dart';
import '../shared/push_notifications/bloc/push_notifications_bloc.dart';
import '../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../shared/utils/observer_utils.dart';
import 'constants.dart';

GoRouter router(BuildContext context, navigatorKey) => GoRouter(
      navigatorKey: navigatorKey,
      observers: [routeObserver],
      routes: <RouteBase>[
        GoRoute(
          path: rootScreenPath,
          builder: (context, state) => HomePage.route(),
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
            return HomePage.route();
          },
          routes: [
            GoRoute(
              path: conversationScreenSubPath,
              builder: (context, state) {
                var extra = state.extra ??
                    context.read<PushNotificationsBloc>().state.conversation;
                return ConversationPage.route(extra);
              },
            )
          ],
        ),
        //TODO RP can be deleted if not used
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
            return GroupCreatePage.route();
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
        GoRoute(
          path: groupInfoPath,
          builder: (context, state) {
            return GroupInfoPage.route(state.extra);
          },
        ),
      ],
      refreshListenable: GoRouterRefreshBloc(
        BlocProvider.of<AuthenticationBloc>(context),
        BlocProvider.of<SharingIntentBloc>(context),
        BlocProvider.of<PushNotificationsBloc>(context),
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

        if (context.read<PushNotificationsBloc>().state.status ==
                PushNotificationsStatus.clicked &&
            status == AuthenticationStatus.authenticated) {
          print('refreshListenable status notification clicked');
          context
              .read<PushNotificationsBloc>()
              .add(PushNotificationsProcessing());
        }

        if (context.read<PushNotificationsBloc>().state.status ==
                PushNotificationsStatus.processing &&
            status == AuthenticationStatus.authenticated) {
          print('refreshListenable status notification processing');
          context
              .read<PushNotificationsBloc>()
              .add(PushNotificationsCompleted());
          if (context.read<PushNotificationsBloc>().state.conversation !=
              null) {
            return ('$conversationListScreenPath/$conversationScreenSubPath');
          }
        }

        if (status == AuthenticationStatus.authenticated) {
          // fix for https://github.com/flutter/flutter/issues/146616 - ignoring Failed assertion for now
          if (state.fullPath ==
                  '$conversationListScreenPath/$conversationScreenSubPath' &&
              state.extra == null) {
            context.goNamed(state.matchedLocation);
          }

          return state.fullPath == loginScreenPath
              ? rootScreenPath
              : state.fullPath;
        } else {
          return BlocProvider.of<AuthenticationBloc>(context)
              .tryGetHasCurrentUser()
              .then((hasUser) {
            return hasUser
                ? state.fullPath == rootScreenPath
                    ? conversationListScreenPath
                    : state.fullPath
                : loginScreenPath;
          });
        }
      },
    );

// The router Bloc that required to manage the user authorisation state and sharing feature at any app point.
// When authorisation state was changer the router will catch this event and redirect to the right screen
class GoRouterRefreshBloc extends ChangeNotifier {
  GoRouterRefreshBloc(AuthenticationBloc authBloc, SharingIntentBloc sharedBloc,
      PushNotificationsBloc notificationsBloc) {
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
    _notificationsBloc = notificationsBloc.stream.listen(
      (PushNotificationsState state) {
        if (state.status == PushNotificationsStatus.clicked ||
            state.status == PushNotificationsStatus.processing) {
          print(
              '[GoRouterRefreshBloc][listen] notification clicked/processing state: $state');
          notifyListeners();
        }
      },
    );
  }

  late final StreamSubscription<AuthenticationState> _blocStream;
  late final StreamSubscription<SharingIntentState> _sharedBloc;
  late final StreamSubscription<PushNotificationsState> _notificationsBloc;

  @override
  void dispose() {
    _blocStream.cancel();
    _sharedBloc.cancel();
    _notificationsBloc.cancel();
    super.dispose();
  }
}
