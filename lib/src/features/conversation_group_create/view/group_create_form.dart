import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../db/models/user_model.dart';
import '../../../features/conversation_create/bloc/conversation_create_event.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/participants_forms.dart';
import '../../../shared/utils/api_utils.dart';
import '../../../shared/utils/screen_factor.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../../search/view/search_bar.dart';
import '../bloc/group_bloc.dart';
import '../models/groupname.dart';

class GroupCreateForm extends StatefulWidget {
  const GroupCreateForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupCreateFormState();
  }
}

class GroupCreateFormState extends State<GroupCreateForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GlobalSearchBar(),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
            child: BlocListener<GroupBloc, GroupState>(
              listener: (context, state) {
                if (state.status.isInitial) {
                } else if (state.status.isFailure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? '')),
                    );
                } else if (state.status.isSuccess) {
                  context
                      .read<ConversationCreateBloc>()
                      .add(ConversationGroupCreated(
                        users: state.participants.value.toList(),
                        type: 'g',
                        name: state.groupname.value,
                        avatarUrl: state.avatar.value,
                      ));
                }
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                    child: BlocBuilder<GroupBloc, GroupState>(
                        buildWhen: (previous, current) {
                  return previous.participants != current.participants;
                }, builder: (context, state) {
                  var users = state.participants.value;
                  return ParticipantsForm(
                    users: List.of(users),
                    onAddParticipants: (user) {
                      context
                          .read<GroupBloc>()
                          .add(GroupParticipantsAdded(user));
                    },
                    onRemoveParticipants: (user) {
                      context
                          .read<GroupBloc>()
                          .add(GroupParticipantsRemoved(user));
                    },
                  );
                }))
              ]),
            )),
        floatingActionButton:
            BlocBuilder<GroupBloc, GroupState>(buildWhen: (previous, current) {
          return previous.participants != current.participants;
        }, builder: (context, state) {
          return Visibility(
            visible: !keyboardIsOpen(context),
            child: Visibility(
              visible: state.participants.isValid,
              child: FloatingActionButton(
                backgroundColor: slateBlue,
                tooltip: 'Next',
                onPressed: () {
                  _showGroupDetails(context);
                },
                child: const Icon(Icons.arrow_forward, color: white, size: 28),
              ),
            ),
          );
        }));
  }
}

void _showGroupDetails(BuildContext context) {
  showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => Dialog.fullscreen(
              child: Scaffold(
            appBar: AppBar(
              backgroundColor: black,
              leading: const BackButton(color: white),
              title: const Text(
                "New group",
                style: TextStyle(color: white),
              ),
              centerTitle: true,
            ),
            body: BlocProvider.value(
                value: BlocProvider.of<GroupBloc>(context),
                child: _GroupDetailsForm()),
            floatingActionButton: Visibility(
              visible: !keyboardIsOpen(context),
              child: FloatingActionButton(
                backgroundColor: slateBlue,
                tooltip: 'Create chat',
                onPressed: () {
                  context.read<GroupBloc>().add(GroupSubmitted());
                },
                child: const Icon(Icons.check, color: white, size: 28),
              ),
            ),
          )));
}

class _GroupInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Group info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ));
  }
}

class _GroupDetailsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var users = context.read<GroupBloc>().state.participants.value;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _GroupInfoWidget(),
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _GroupAvatar(),
            ),
            Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 12.0),
                child: _GroupNameInput(),
              ),
            ]))
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Participants ${users.length}/$maxParticipantsCount',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          Expanded(child: _Participants(users: List.of(users)))
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
            key: const Key('groupCreateForm_groupnameInput_textField'),
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

class _Participants extends StatelessWidget {
  const _Participants({required this.users});

  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final user = users[index];
        return ListTile(
          leading: AvatarLetterIcon(name: user.login!, avatar: user.avatar),
          title: Text(
            user.login!,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: const EdgeInsets.fromLTRB(0.0, 8.0, 18.0, 8.0),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(color: slateBlue);
      },
    );
  }
}
