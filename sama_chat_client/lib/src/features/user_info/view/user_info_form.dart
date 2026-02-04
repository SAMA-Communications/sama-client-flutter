import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/user_model.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/user_forms.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_event.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';

class UserInfoForm extends StatelessWidget {
  final UserModel user;

  const UserInfoForm({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return UserInfoCard(user: user);
  }
}

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: Platform.isIOS ? 0.0 : 4.0),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Stack(children: [
                  Align(
                    alignment: const Alignment(0, -0.5),
                    child: IntrinsicHeight(
                      child: Stack(children: [
                        Card(
                          color: paleMallow,
                          margin: const EdgeInsets.only(top: 40),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 50, left: 4, right: 4, bottom: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UsernameForm(userLogin: user.login),
                                const SizedBox(height: columnItemMargin),
                                UserPhoneForm(userPhone: user.phone),
                                const SizedBox(height: columnItemMargin),
                                UserEmailForm(userEmail: user.email),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, -1.03),
                          child: AvatarForm(avatar: user.avatar?.imageUrl),
                        ),
                      ]),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: _StartConversationForm(user: user))
                ]))));
  }
}

class _StartConversationForm extends StatelessWidget {
  final UserModel user;

  const _StartConversationForm({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationCreateBloc, ConversationCreateState>(
        listener: (context, state) {
          if (state is ConversationCreatedLoading) {
            // loadingOverlay.show(context);// for now disable
          } else if (state is ConversationCreatedState) {
            // loadingOverlay.hide();// for now disable
            final conversation = state.conversation;
            Navigator.popUntil(context, (route) => route.isFirst);
            context.go('$conversationListScreenPath/$conversationScreenSubPath',
                extra: conversation);
          } else if (state is ConversationCreatedStateError) {
            // loadingOverlay.hide();// for now disable
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? '')),
              );
          }
        },
        child: TextButton.icon(
            label: const Text("Start a conversation",
                style: TextStyle(fontSize: 20, color: slateBlue)),
            icon: const Icon(Icons.arrow_forward, color: slateBlue, size: 25),
            iconAlignment: IconAlignment.end,
            onPressed: () => context.read<ConversationCreateBloc>().add(
                  ConversationCreated(user: user, type: 'u'),
                )));
  }
}
