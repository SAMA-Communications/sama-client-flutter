import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../db/models/user_model.dart';
import '../../../features/user_info/view/user_info_form.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';

class UserInfoPage extends StatelessWidget {
  final UserModel user;

  const UserInfoPage({required this.user, super.key});

  static BlocProvider route(Object? extra) {
    UserModel user = extra as UserModel;
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
          iconTheme: const IconThemeData(
            color: white, //change your color here
          ),
          title: Text(
            getUserModelName(user),
            style: const TextStyle(color: white),
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
        ),
        body: UserInfoForm(user: user));
  }
}
