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
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          HeaderCard(),
          FooterCard(),
        ]));
  }
}

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});

  final arrowBackSize = 30.0;

  @override
  Widget build(BuildContext context) {
    var isOwner = context.read<GroupInfoBloc>().state.conversation.owner?.id ==
        context.read<AuthenticationBloc>().state.user.id!;

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
            context.pop(context.read<GroupInfoBloc>().state.status.isSuccess);
          },
        ),
        title: Center(
          child: Padding(
              padding: EdgeInsets.only(right: arrowBackSize, top: 8),
              child: _ChatAvatar(isOwner: isOwner)),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(right: arrowBackSize, bottom: 4),
          child: _ChatNameDescription(isOwner: isOwner),
        ),
      ),
    );
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
            previous.name != current.name && current.name.isPure ||
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
                child: Column(children: [
                  Text(
                    state.name.value.isEmpty ? "Group name" : state.name.value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: state.name.value.isEmpty
                            ? FontWeight.w200
                            : FontWeight.bold,
                        color: signalBlack),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state.description.value.isEmpty
                        ? "Description"
                        : state.description.value,
                    style: TextStyle(
                        fontSize: 18,
                        color: signalBlack,
                        fontWeight: state.description.value.isEmpty
                            ? FontWeight.w200
                            : FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
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

class FooterCard extends StatelessWidget {
  const FooterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupInfoBloc, GroupInfoState>(
        buildWhen: (previous, current) =>
            previous.participants != current.participants,
        builder: (context, state) {
          var ownerId = state.conversation.owner?.id ?? '';
          var localUserId = context.read<AuthenticationBloc>().state.user.id!;
          var isOwner = ownerId == localUserId;
          return Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(children: [
                            _ParticipantsHeaderForm(isOwner: isOwner),
                            Expanded(
                                child: _ParticipantsListForm(
                                    isOwner: isOwner,
                                    ownerId: ownerId,
                                    localUserId: localUserId)),
                          ]),
                        ),
                      ))));
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
  final String localUserId;

  const _ParticipantsListForm(
      {required this.isOwner,
      required this.ownerId,
      required this.localUserId});

  @override
  Widget build(BuildContext context) {
    var state = context.read<GroupInfoBloc>().state;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.participants.value.length,
      itemBuilder: (BuildContext context, int index) {
        final user = state.participants.value.elementAt(index);
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
            user.id == localUserId
                ? context.push(profilePath)
                : context.push(userInfoPath, extra: user);
          },
          trailing: isOwner && user.id != localUserId
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
  bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
  showDialog(
      context: context,
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
                      return ParticipantsForm(
                        users: List.of(state.addParticipants.value),
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
                  visible: !keyboardIsOpen,
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
