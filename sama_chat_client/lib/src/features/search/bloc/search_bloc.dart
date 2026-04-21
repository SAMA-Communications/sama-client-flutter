import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../db/models/models.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/user/user_repository.dart';

part 'search_event.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ConversationRepository conversationRepository;
  final UserRepository userRepository;

  SearchBloc(this.conversationRepository, this.userRepository)
      : super(const SearchState()) {
    on<UsersRecent>(_onUsersRecent);

    add(UsersRecent());
  }

  Future<void> _onUsersRecent(event, emit) async {
    var lim = 10;
    var currentUserId = await userRepository.getCurrentUserId();
    var chats = await conversationRepository.getStoredConversations(
        limit: lim, type: 'u');
    if (chats.length < lim) {
      chats.addAll(await conversationRepository.getStoredConversations(
          limit: lim, type: 'g'));
    }
    List<UserModel> users = chats
        .map((chat) => chat.participants.toList())
        .flattenedToSet
        .where((u) => u.id != currentUserId)
        .take(lim)
        .toList();

    emit(
      state.copyWith(
        users: users,
      ),
    );
  }
}
