import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../api/api.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/user_forms.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversation_create/bloc/conversation_create_event.dart';
import '../../conversation_create/bloc/conversation_create_state.dart';

class UserInfoForm extends StatelessWidget {
  final User user;

  const UserInfoForm({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      HeaderCard(user: user),
      FooterCard(user: user),
    ]);
  }
}

class HeaderCard extends StatelessWidget {
  final User user;

  const HeaderCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: AvatarForm(avatar: user.avatar?.imageUrl),
          ),
        ),
      ),
    );
  }
}

class FooterCard extends StatelessWidget {
  final User user;

  const FooterCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: Platform.isIOS ? 0.0 : 4.0),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UsernameForm(userLogin: user.login),
                  const SizedBox(height: columnItemMargin),
                  UserPhoneForm(userPhone: user.phone),
                  const SizedBox(height: columnItemMargin),
                  UserEmailForm(userEmail: user.email),
                  const SizedBox(height: columnItemMargin),
                  _StartConversationForm(user: user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartConversationForm extends StatelessWidget {
  final User user;

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
        child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
                child: const Text("Start a conversation",
                    style: TextStyle(fontSize: 20, color: slateBlue)),
                onPressed: () => context.read<ConversationCreateBloc>().add(
                      ConversationCreated(user: user, type: 'u'),
                    ))));
  }
}
