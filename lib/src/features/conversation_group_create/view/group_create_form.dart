import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../../../features/conversation_create/bloc/conversation_create_event.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/participants_forms.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../bloc/group_bloc.dart';
import '../models/groupname.dart';

class GroupForm extends StatefulWidget {
  const GroupForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupFormState();
  }
}

class GroupFormState extends State<GroupForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state.status.isInitial) {
          } else if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '')),
              );
          } else if (state.status.isSuccess) {
            context.read<ConversationCreateBloc>().add(ConversationGroupCreated(
                  users: state.participants.value.toList(),
                  type: 'g',
                  name: state.groupname.value,
                  avatarUrl: state.avatar.value,
                ));
          }
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Group info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: _GroupAvatar(),
            ),
            Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Group name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: _GroupNameInput(),
              ),
            ]))
          ]),
          Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                  buildWhen: (previous, current) {
            return previous.participants != current.participants;
          }, builder: (context, state) {
            var users = state.participants.value;
            return ParticipantsForm(
              users: List.of(users),
              onAddParticipants: (user) {
                context.read<GroupBloc>().add(GroupParticipantsAdded(user));
              },
              onRemoveParticipants: (user) {
                context.read<GroupBloc>().add(GroupParticipantsRemoved(user));
              },
            );
          }))
        ]));
  }
}

class _GroupAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
        buildWhen: (previous, current) => previous.avatar != current.avatar,
        builder: (context, state) {
          return GestureDetector(
              onTap: () => context.read<GroupBloc>().add(GroupAvatarPicked()),
              child: Container(
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  height: 60.0,
                  width: 60.0,
                  child: Center(child: () {
                    if (state.avatar.value == null) {
                      return const Icon(
                        Icons.image_outlined,
                        color: dullGray,
                        size: 50.0,
                      );
                    }
                    {
                      return Image.file(
                        state.avatar.value!,
                        height: 60.0,
                        width: 60.0,
                        fit: BoxFit.cover,
                      );
                    }
                  }())));
        });
  }
}

class _GroupNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      buildWhen: (previous, current) => previous.groupname != current.groupname,
      builder: (context, state) {
        return Container(
          height: 60.0,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: gainsborough,
          ),
          child: TextField(
            key: const Key('groupForm_groupnameInput_textField'),
            keyboardType: TextInputType.text,
            onChanged: (groupname) =>
                context.read<GroupBloc>().add(GroupnameChanged(groupname)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 4),
              label: const Row(
                children: [
                  Icon(
                    Icons.group,
                    size: 16,
                    color: dullGray,
                  ),
                  Text(
                    'Groupname',
                    style: TextStyle(color: dullGray, fontSize: 16),
                  )
                ],
              ),
              errorText: state.groupname.displayError != null
                  ? state.groupname.displayError ==
                          GroupnameValidationError.short
                      ? 'Group name is too short'
                      : null
                  : null,
            ),
          ),
        );
      },
    );
  }
}
