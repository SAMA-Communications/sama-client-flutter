import 'package:bloc/bloc.dart';
import 'package:sama_client_flutter/src/repository/global_search/global_search_repository.dart';
import 'package:stream_transform/stream_transform.dart';

import '../bloc/global_search_event.dart';
import '../bloc/global_search_state.dart';
import '../models/search_result_error.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  GlobalSearchBloc({required this.globalSearchRepository})
      : super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
  }

  final GlobalSearchRepository globalSearchRepository;

  Future<void> _onTextChanged(
    TextChanged event,
    Emitter<GlobalSearchState> emit,
  ) async {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) return emit(SearchStateEmpty());

    emit(SearchStateLoading());

    try {
      final results = await globalSearchRepository.search(searchTerm);
      emit(SearchStateSuccess(results.users, results.conversations));
    } catch (error) {
      emit(
        error is SearchResultError
            ? SearchStateError(error.message)
            : const SearchStateError('something went wrong'),
      );
    }
  }
}
