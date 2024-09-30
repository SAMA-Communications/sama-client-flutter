import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../features/user_info/view/user_info_form.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';

class UserInfoPage extends StatelessWidget {
  final User user;

  const UserInfoPage({required this.user, super.key});

  static BlocProvider route(Object? extra) {
    User user = extra as User;
    return BlocProvider<ConversationCreateBloc>(
        create: (context) => ConversationCreateBloc(
              conversationRepository:
                  RepositoryProvider.of<ConversationRepository>(context),
            ),
        child: UserInfoPage(user: user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: black,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Image.asset(
              'assets/images/vector_logo.png',
              width: 32,
              fit: BoxFit.cover,
            ),
            onPressed: () {},
          ),
          title: const Text(
            'User information',
            style: TextStyle(color: white),
          ),
        ),
        body: UserInfoForm(user: user));
  }
}
