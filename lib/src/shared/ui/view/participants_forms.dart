import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../api/utils/screen_factor.dart';
import '../../../features/conversations_list/widgets/avatar_letter_icon.dart';
import '../../../features/search/bloc/global_search_bloc.dart';
import '../../../features/search/bloc/global_search_state.dart';
import '../../utils/api_utils.dart';
import '../../utils/string_utils.dart';
import '../colors.dart';

class ParticipantsForm extends StatelessWidget {
  const ParticipantsForm(
      {required this.users,
      required this.onAddParticipants,
      required this.onRemoveParticipants,
      this.nonRemovableUsers,
      super.key});

  final List<User> users;
  final List<User>? nonRemovableUsers;
  final ValueSetter<User> onAddParticipants;
  final ValueSetter<User> onRemoveParticipants;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text('Add participants',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      LimitedBox(
        maxHeight: heightScreen / 5.5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ParticipantsList(
              users: users,
              nonRemovableUsers: nonRemovableUsers,
              onRemoveParticipants: onRemoveParticipants),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('List of users ${users.length}/$maxParticipantsCount',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
      _SearchBody(
          selectedUsers: users,
          onAddParticipants: onAddParticipants,
          onRemoveParticipants: onRemoveParticipants)
    ]);
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody(
      {required this.selectedUsers,
      required this.onAddParticipants,
      required this.onRemoveParticipants});

  final List<User> selectedUsers;
  final ValueSetter<User> onAddParticipants;
  final ValueSetter<User> onRemoveParticipants;

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
              child: _SearchResults(
                  users: state.users,
                  selectedUsers: selectedUsers,
                  onAddParticipants: onAddParticipants,
                  onRemoveParticipants: onRemoveParticipants),
            ),
        };
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults(
      {required this.users,
      required this.selectedUsers,
      required this.onAddParticipants,
      required this.onRemoveParticipants});

  final List<User> users;
  final List<User> selectedUsers;
  final ValueSetter<User> onAddParticipants;
  final ValueSetter<User> onRemoveParticipants;

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
        : ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                trailing: selectedUsers.contains(user)
                    ? const Icon(Icons.circle_rounded, color: slateBlue)
                    : const Icon(Icons.circle_outlined),
                contentPadding: const EdgeInsets.fromLTRB(0.0, 4.0, 18.0, 4.0),
                onTap: () {
                  selectedUsers.contains(user)
                      ? onRemoveParticipants(user)
                      : onAddParticipants(user);
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(color: lightMallow);
            },
          );

    return userList;
  }
}

class ParticipantsList extends StatelessWidget {
  const ParticipantsList(
      {required this.users,
      required this.nonRemovableUsers,
      required this.onRemoveParticipants,
      super.key});

  final List<User> users;
  final List<User>? nonRemovableUsers;
  final ValueSetter<User> onRemoveParticipants;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      childAspectRatio: 4 / 4,
      //or 5 / 4 for crossAxisCount: 4
      crossAxisCount: 5,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      children: List.generate(users.length, (index) {
        var user = users.elementAt(index);
        return _ParticipantsListItem(
            user: user,
            removable: nonRemovableUsers?.contains(user) != true,
            onRemoveParticipants: onRemoveParticipants);
      }),
    );
  }
}

class _ParticipantsListItem extends StatelessWidget {
  const _ParticipantsListItem(
      {required this.user,
      required this.removable,
      required this.onRemoveParticipants});

  final User user;
  final bool removable;
  final ValueSetter<User> onRemoveParticipants;

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
                padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 4.0),
                size: const Size(50.0, 50.0),
              ),
              removable
                  ? Positioned(
                      top: -2,
                      right: -2,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(6.0),
                          onTap: () {
                            onRemoveParticipants(user);
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: gainsborough,
                          )))
                  : const SizedBox.shrink(),
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
