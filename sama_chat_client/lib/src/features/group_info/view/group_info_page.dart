import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/conversation_model.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/user/user_repository.dart';
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
          RepositoryProvider.of<UserRepository>(context),
          conversation: conversation),
      child: GroupInfoPage(conversation: conversation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        builder: (context, state) {
      return PopScope(
          canPop: false,
          child: Scaffold(
              backgroundColor: black,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_outlined, color: white),
                  onPressed: () => context.pop(state.status.isSuccess),
                ),
                title: Text(
                  state.name.value,
                  style: const TextStyle(color: white),
                  overflow: TextOverflow.ellipsis,
                ),
                centerTitle: true,
              ),
              body: const GroupInfoForm()));
    });
  }
}
