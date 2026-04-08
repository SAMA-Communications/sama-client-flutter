import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:sama_sdk/api/settings.dart';

import '../../../db/models/user_model.dart';
import '../../../features/conversation_create/bloc/conversation_create_event.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/participants_forms.dart';
import '../../../shared/ui/view/text_button_forms.dart';
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
        appBar: AppBar(
            backgroundColor: black,
            leading: const BackButton(color: white),
            centerTitle: true,
            title: const Text(
              'Group create',
              style: TextStyle(color: white),
            )),
        body: BlocListener<GroupBloc, GroupState>(
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    const GlobalSearchBar(hintText: 'Search for people to add'),
                    Expanded(
                        child: BlocBuilder<GroupBloc, GroupState>(
                            buildWhen: (previous, current) {
                      return previous.participants != current.participants;
                    }, builder: (context, state) {
                      var users = state.participants.value;
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ParticipantsForm(
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
                          ));
                    }))
                  ]),
            )),
        floatingActionButton:
            BlocBuilder<GroupBloc, GroupState>(buildWhen: (previous, current) {
          return previous.participants != current.participants;
        }, builder: (context, state) {
          return Visibility(
            visible: !keyboardIsOpenCtx(context) && state.participants.isValid,
            child: IntrinsicWidth(
              child: ButtonForm(
                  onPressed: () {
                    _showGroupDetails(context);
                  },
                  backgroundColor: WidgetStatePropertyAll(
                      state.participants.isValid ? slateBlue : whiteAluminum),
                  foregroundColor: WidgetStatePropertyAll(
                      state.participants.isValid ? white : gainsborough),
                  text: 'Next',
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
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
                visible: !keyboardIsOpenCtx(context),
                child: IntrinsicWidth(
                  child: ButtonForm(
                      onPressed: () {
                        context.read<GroupBloc>().add(GroupSubmitted());
                      },
                      backgroundColor: const WidgetStatePropertyAll(slateBlue),
                      foregroundColor: const WidgetStatePropertyAll(white),
                      text: 'Create',
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                )),
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
              child: Text('Participants ${users.length + 1}/$maxParticipants',
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
                  decoration: const BoxDecoration(
                    color: black,
                    shape: BoxShape.circle,
                  ),
                  height: 60.0,
                  width: 60.0,
                  child: Center(child: ClipOval(child: () {
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
                  }()))));
        });
  }
}

class _GroupNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      buildWhen: (previous, current) => previous.groupname != current.groupname,
      builder: (context, state) {
        return TextFieldForm(
            onChanged: (groupname) =>
                context.read<GroupBloc>().add(GroupnameChanged(groupname)),
            iconData: Icons.group,
            text: 'Groupname',
            error: state.groupname.displayError != null
                ? state.groupname.displayError == GroupnameValidationError.short
                    ? 'Group name is too short'
                    : null
                : null);
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
