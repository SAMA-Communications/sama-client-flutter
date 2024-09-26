import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../../../features/conversation_create/bloc/conversation_create_event.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../conversation_create/bloc/conversation_create_bloc.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';
import '../../search/bloc/global_search_bloc.dart';
import '../../search/bloc/global_search_state.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: _GroupNameInput(),
                ),
              ]))
            ]),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text('Add participants',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            LimitedBox(
              maxHeight: 128,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _ParticipantsGrid(),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('List of users',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _SearchBody()
          ],
        ));
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

class _ParticipantsGrid extends StatefulWidget {
  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<_ParticipantsGrid> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      buildWhen: (previous, current) {
        return previous.participants != current.participants;
      },
      builder: (context, state) {
        var users = state.participants.value;
        return GridView.count(
          shrinkWrap: true,
          childAspectRatio: 4 / 4,
          //or 5 / 4 for crossAxisCount: 4
          crossAxisCount: 5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          children: List.generate(users.length, (index) {
            return _ParticipantsListItem(user: users.elementAt(index));
          }),
        );
      },
    );
  }
}

class _ParticipantsListItem extends StatelessWidget {
  const _ParticipantsListItem({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 40,
            height: 40,
            child: Stack(fit: StackFit.expand, children: [
              AvatarLetterIcon(
                name: getUserName(user),
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
              ),
              Positioned(
                  top: -2,
                  right: -2,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(6.0),
                      onTap: () {
                        context
                            .read<GroupBloc>()
                            .add(GroupParticipantsRemoved(user));
                      },
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: gainsborough,
                      )))
            ])),
        Text(
          getUserName(user),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.0,
            fontFamily: 'Roboto',
            color: dullGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: Text('Please start typing to find user'),
            ),
          SearchStateLoading() => const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: CircularProgressIndicator.adaptive(),
            ),
          SearchStateError() => Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(state.error),
            ),
          SearchStateSuccess() => Expanded(
              child: _SearchResults(users: state.users),
            ),
        };
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.users});

  final List<User> users;

  Widget _emptyListText(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userList = users.isEmpty
        ? _emptyListText('We couldn\'t find the specified users')
        : ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              return ListTile(
                leading:
                    AvatarLetterIcon(name: user.login!, avatar: user.avatar),
                title: Text(
                  user.login!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.fromLTRB(0.0, 8.0, 18.0, 8.0),
                onTap: () {
                  context.read<GroupBloc>().add(GroupParticipantsAdded(user));
                },
              );
            },
          );

    return userList;
  }
}
