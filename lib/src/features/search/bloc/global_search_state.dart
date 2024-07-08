
import 'package:equatable/equatable.dart';

import '../models/search_result_item.dart';

sealed class GlobalSearchState extends Equatable {
  const GlobalSearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends GlobalSearchState {}

final class SearchStateLoading extends GlobalSearchState {}

final class SearchStateSuccess extends GlobalSearchState {
  const SearchStateSuccess(this.items);

  final List<SearchResultItem> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

final class SearchStateError extends GlobalSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}