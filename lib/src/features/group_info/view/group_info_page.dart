import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../db/models/conversation.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../shared/ui/colors.dart';
import '../bloc/group_info_bloc.dart';
import 'group_info_form.dart';

class GroupInfoPage extends StatelessWidget {
  final ConversationModel conversation;

  const GroupInfoPage({required this.conversation, super.key});

  static BlocProvider route(Object? extra) {
    ConversationModel conversation = extra as ConversationModel;

    return BlocProvider<GroupInfoBloc>(
      create: (context) => GroupInfoBloc(
          RepositoryProvider.of<ConversationRepository>(context),
          conversation: conversation),
      child: GroupInfoPage(conversation: conversation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: black,
          automaticallyImplyLeading: false,
          title: const Text(
            'Chat information',
            style: TextStyle(color: white),
          ),
          centerTitle: true,
        ),
        body: const GroupInfoForm());
  }
}
