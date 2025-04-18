import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../repository/global_search/global_search_repository.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/participants_forms.dart';
import '../../../shared/ui/view/user_forms.dart';
import '../../../shared/utils/screen_factor.dart';
import '../../../shared/utils/string_utils.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../../search/bloc/global_search_bloc.dart';
import '../../search/view/search_bar.dart';
import '../bloc/group_info_bloc.dart';
import '../models/models.dart';

class GroupInfoForm extends StatelessWidget {
  const GroupInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupInfoBloc, GroupInfoState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '')),
              );
          } else if (state.status.isSuccess &&
              state.informationMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.informationMessage ?? '')),
              );
          }
        },
        child: const GroupInfoCard());
  }
}

class AvatarDescriptionTile extends StatelessWidget {
  const AvatarDescriptionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        builder: (context, state) {
      var isOwner =
          context.read<GroupInfoBloc>().state.conversation.owner?.id ==
              context.read<GroupInfoBloc>().state.currentUser?.id;
      return ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        title: Center(
          child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ChatAvatar(isOwner: isOwner)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _ChatNameDescription(isOwner: isOwner),
        ),
      );
    });
  }
}

class _ChatAvatar extends StatelessWidget {
  final bool isOwner;

  const _ChatAvatar({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        buildWhen: (previous, current) => previous.avatar != current.avatar,
        builder: (context, state) {
          return GestureDetector(
              onTap: () => isOwner
                  ? context.read<GroupInfoBloc>().add(GroupAvatarPicked())
                  : null,
              child: AvatarForm(
                avatar: state.avatar.value,
              ));
        });
  }
}

class _ChatNameDescription extends StatelessWidget {
  final bool isOwner;

  const _ChatNameDescription({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        buildWhen: (previous, current) =>
            previous.description != current.description &&
            current.description.isPure,
        builder: (context, state) {
          return Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: isOwner
                    ? () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return BlocProvider.value(
                                value: BlocProvider.of<GroupInfoBloc>(context),
                                child: const NameDialogInput(),
                              );
                            });
                      }
                    : null,
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center),
                child: Text(
                  state.description.value.isEmpty
                      ? "Description"
                      : state.description.value,
                  style: TextStyle(
                      fontSize: 18,
                      color: signalBlack,
                      fontWeight: state.description.value.isEmpty
                          ? FontWeight.w200
                          : FontWeight.normal),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ));
        });
  }
}

class NameDialogInput extends StatelessWidget {
  const NameDialogInput({super.key});

  @override
  Widget build(BuildContext context) {
    var groupNameTxt = TextEditingController()
      ..text = context.read<GroupInfoBloc>().state.name.value;
    var descriptionTxt = TextEditingController()
      ..text = context.read<GroupInfoBloc>().state.description.value;

    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        buildWhen: (previous, current) =>
            previous.name != current.name ||
            previous.description != current.description,
        builder: (context, state) {
          return AlertDialog(
              title: const Text('Edit chat information'),
              actionsPadding: const EdgeInsets.only(bottom: 8),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: gainsborough,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: groupNameTxt,
                    style: const TextStyle(fontSize: 18),
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    onChanged: (groupname) => context
                        .read<GroupInfoBloc>()
                        .add(GroupNameChanged(groupname)),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 4),
                      label: const Text(
                        'Group name',
                        style: TextStyle(color: dullGray, fontSize: 16),
                      ),
                      errorText: state.name.displayError ==
                              GroupnameValidationError.empty
                          ? 'group name is empty'
                          : state.name.displayError ==
                                  GroupnameValidationError.short
                              ? 'group name is too short'
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: columnItemMargin),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: gainsborough,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: descriptionTxt,
                    style: const TextStyle(fontSize: 18),
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    onChanged: (description) => context
                        .read<GroupInfoBloc>()
                        .add(GroupDescriptionChanged(description)),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 4),
                      label: const Text(
                        'Description',
                        style: TextStyle(color: dullGray, fontSize: 16),
                      ),
                      errorText: state.description.displayError ==
                              GroupDescriptionValidationError.empty
                          ? 'group description is empty'
                          : state.description.displayError ==
                                  GroupDescriptionValidationError.short
                              ? 'group description is too short'
                              : null,
                    ),
                  ),
                ),
              ]),
              actions: _formActions(context));
        });
  }
}

class GroupInfoCard extends StatelessWidget {
  const GroupInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        buildWhen: (previous, current) =>
            previous.participants != current.participants,
        builder: (context, state) {
          var ownerId = state.conversation.owner?.id ?? '';
          var currentUserId =
              context.read<GroupInfoBloc>().state.currentUser?.id ?? '';
          var isOwner = ownerId == currentUserId;
          return Padding(
              padding: EdgeInsets.only(bottom: Platform.isIOS ? 0.0 : 4.0),
              child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(children: [
                        const AvatarDescriptionTile(),
                        _ParticipantsHeaderForm(isOwner: isOwner),
                        Expanded(
                            child: _ParticipantsListForm(
                                isOwner: isOwner,
                                ownerId: ownerId,
                                currentUserId: currentUserId)),
                      ]),
                    ),
                  )));
        });
  }
}

class _ParticipantsHeaderForm extends StatelessWidget {
  final bool isOwner;

  const _ParticipantsHeaderForm({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    var state = context.read<GroupInfoBloc>().state;
    return ListTile(
      contentPadding: const EdgeInsets.all(8.0),
      leading: Text(
        '${state.participants.value.length} members',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      trailing: isOwner
          ? IconButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              icon: const Icon(Icons.person_add_alt_outlined,
                  color: signalBlack, size: 30),
              onPressed: () {
                _showSearchScreenDialog(context);
              },
            )
          : null,
    );
  }
}

class _ParticipantsListForm extends StatelessWidget {
  final bool isOwner;
  final String ownerId;
  final String currentUserId;

  const _ParticipantsListForm(
      {required this.isOwner,
      required this.ownerId,
      required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    var state = context.read<GroupInfoBloc>().state;
    var participants = state.participants.value.toList()
      ..sort((a, b) => a.login!.compareTo(b.login!));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: participants.length,
      itemBuilder: (BuildContext context, int index) {
        final user = participants.elementAt(index);
        return ListTile(
          leading: AvatarLetterIcon(name: user.login!, avatar: user.avatar),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              getUserName(user),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (user.id == ownerId)
              const Text(
                'admin',
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
              ),
          ]),
          contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          onTap: () {
            user.id == currentUserId
                ? context.push(profilePath)
                : context.push(userInfoPath, extra: user);
          },
          trailing: isOwner && user.id != currentUserId
              ? IconButton(
                  icon: const Icon(Icons.person_remove_outlined,
                      color: signalBlack),
                  onPressed: () {
                    context
                        .read<GroupInfoBloc>()
                        .add(GroupRemoveParticipants(user));
                    _showRemoveParticipantsDialog(context);
                  },
                )
              : null,
        );
      },
    );
  }
}

void _showSearchScreenDialog(BuildContext context) {
  showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => Dialog.fullscreen(
          child: BlocProvider<GlobalSearchBloc>(
              create: (context) => GlobalSearchBloc(
                    globalSearchRepository:
                        RepositoryProvider.of<GlobalSearchRepository>(context),
                  ),
              child: Scaffold(
                appBar: const GlobalSearchBar(),
                body: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                  child: BlocProvider.value(
                    value: BlocProvider.of<GroupInfoBloc>(context),
                    child: BlocConsumer<GroupInfoBloc, GroupInfoState>(
                        listener: (context, state) {
                      if (state.addParticipants.displayError ==
                          GroupParticipantsValidationError.long) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'you\'ve reached maximum participant limit')),
                          );
                      }
                    }, buildWhen: (previous, current) {
                      return previous.addParticipants !=
                          current.addParticipants;
                    }, builder: (context, state) {
                      var currentParticipants = List.of(
                          state.participants.value..remove(state.currentUser));
                      return ParticipantsForm(
                        users: currentParticipants
                          ..addAll(state.addParticipants.value),
                        nonRemovableUsers: currentParticipants,
                        onAddParticipants: (user) {
                          if (!state.participants.value.contains(user)) {
                            context
                                .read<GroupInfoBloc>()
                                .add(GroupAddParticipantsAdded(user));
                          } else {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                    content: Text('user is already in chat')),
                              );
                          }
                        },
                        onRemoveParticipants: (user) {
                          context
                              .read<GroupInfoBloc>()
                              .add(GroupAddParticipantsRemoved(user));
                        },
                      );
                    }),
                  ),
                ),
                floatingActionButton: Visibility(
                  visible: !keyboardIsOpen(context),
                  child: FloatingActionButton(
                    backgroundColor: dullGray,
                    tooltip: 'Add participants',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return BlocProvider.value(
                              value: BlocProvider.of<GroupInfoBloc>(context),
                              child: _AddParticipantsDialog(),
                            );
                          });
                    },
                    child: const Icon(Icons.check, color: white, size: 28),
                  ),
                ),
              ))));
}

void _showRemoveParticipantsDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: BlocProvider.value(
              value: BlocProvider.of<GroupInfoBloc>(context),
              child: _RemoveParticipantsDialog(),
            ));
      });
}

class _AddParticipantsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Add participants', style: TextStyle(fontSize: 20)),
        content: const Text('Add selected users to the chat?',
            style: TextStyle(fontSize: 16)),
        actions: _formActions(context));
  }
}

class _RemoveParticipantsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title:
            const Text('Remove user from chat', style: TextStyle(fontSize: 20)),
        content: const Text('Do you want to delete this user?',
            style: TextStyle(fontSize: 16)),
        actions: _formActions(context));
  }
}

List<Widget> _formActions(BuildContext context) {
  return [
    TextButton(
      onPressed: () {
        context.read<GroupInfoBloc>().add(GroupInfoResetChanges());
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context, 'Cancel');
      },
      child: const Text('Cancel'),
    ),
    TextButton(
      onPressed: () {
        if (context.read<GroupInfoBloc>().state.isValid) {
          context.read<GroupInfoBloc>().add(GroupInfoSubmitted());
          Navigator.popUntil(context, ModalRoute.withName(groupInfoPath));
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: keyboardHeight(context)),
                  content: const Text('Please make changes to the data.')),
            );
        }
      },
      child: const Text('Ok'),
    ),
  ];
}
