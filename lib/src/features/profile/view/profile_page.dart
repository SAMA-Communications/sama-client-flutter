import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/profile/view/profile_form.dart';
import '../../../navigation/constants.dart';
import '../../../repository/user/user_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/widget/env_dialog_widget.dart';
import '../../../shared/widget/multi_gesture_detector.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: black,
          iconTheme: const IconThemeData(
            color: white, //change your color here
          ),
          title: MultiGestureDetector(
            taps: 5,
            onTap: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const EnvDialogInput();
                }),
            child: const Text(
              'Personal information',
              style: TextStyle(color: white),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => context.push(globalSearchPath),
              icon: const Icon(
                Icons.search,
                color: white,
                size: 32,
              ),
            ),
          ],
        ),
        body: BlocProvider(
          create: (context) {
            return ProfileBloc(
              userRepository: RepositoryProvider.of<UserRepository>(context),
            );
          },
          child: const ProfileForm(),
        ));
  }
}
