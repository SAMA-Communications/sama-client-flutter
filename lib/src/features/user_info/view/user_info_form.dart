import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../api/api.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/user_forms.dart';
import '../../../shared/utils/string_utils.dart';
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

  final arrowBackSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        leading: IconButton(
          style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          icon: Icon(Icons.arrow_back_outlined,
              color: signalBlack, size: arrowBackSize),
          onPressed: () {
            context.pop();
          },
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(right: arrowBackSize, top: 8),
            child: UserAvatarForm(userAvatar: user.avatar?.imageUrl),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(right: arrowBackSize, bottom: 4),
          child: _UserFullName(user: user),
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
        padding: const EdgeInsets.only(bottom: 4),
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
                  // const Expanded(
                  //     child: Align(
                  //         alignment: Alignment.bottomLeft,
                  //         child: _RemoveParticipantForm()))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserFullName extends StatelessWidget {
  final User user;

  const _UserFullName({required this.user});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        getUserName(user),
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: signalBlack),
        overflow: TextOverflow.ellipsis,
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

//TODO RP consider to move this to list with participants on group chat
class _RemoveParticipantForm extends StatelessWidget {
  const _RemoveParticipantForm();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.remove_circle_outline, color: red, size: 25),
      style: TextButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft),
      label: const Text(
        'Remove participant',
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }
}
