import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/api.dart';
import '../../../features/conversations_list/widgets/avatar_letter_icon.dart';
import '../../../features/search/bloc/global_search_bloc.dart';
import '../../../features/search/bloc/global_search_state.dart';
import '../../utils/string_utils.dart';
import '../colors.dart';

class ParticipantsForm extends StatelessWidget {
  const ParticipantsForm(
      {required this.users,
      required this.onAddParticipants,
      required this.onRemoveParticipants,
      super.key});

  final List<User> users;
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
      LimitedBox(
        maxHeight: 128,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ParticipantsList(
              users: users, onRemoveParticipants: onRemoveParticipants),
        ),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text('List of users',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      _SearchBody(onAddParticipants: onAddParticipants)
    ]);
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.onAddParticipants});

  final ValueSetter<User> onAddParticipants;

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
                  users: state.users, onAddParticipants: onAddParticipants),
            ),
        };
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.users, required this.onAddParticipants});

  final List<User> users;
  final ValueSetter<User> onAddParticipants;

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
                  onAddParticipants(user);
                },
              );
            },
          );

    return userList;
  }
}

class ParticipantsList extends StatelessWidget {
  const ParticipantsList(
      {required this.users, required this.onRemoveParticipants, super.key});

  final List<User> users;
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
        return _ParticipantsListItem(
            user: users.elementAt(index),
            onRemoveParticipants: onRemoveParticipants);
      }),
    );
  }
}

class _ParticipantsListItem extends StatelessWidget {
  const _ParticipantsListItem(
      {required this.user, required this.onRemoveParticipants});

  final User user;
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
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
              ),
              Positioned(
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
