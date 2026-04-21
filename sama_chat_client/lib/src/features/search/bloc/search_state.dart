part of 'search_bloc.dart';

final class SearchState extends Equatable {
  const SearchState({this.users = const []});

  final List<UserModel> users;

  SearchState copyWith({
    List<UserModel>? users,
  }) {
    return SearchState(users: users ?? this.users);
  }

  @override
  List<Object?> get props => [users];
}
