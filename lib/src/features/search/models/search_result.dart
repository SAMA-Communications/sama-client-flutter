import '../../search/models/search_result_item.dart';

class SearchResult {
  const SearchResult({required this.items});

  factory SearchResult.fromJson(List<dynamic> json) {
    final items = json
        .map(
          (dynamic item) =>
              SearchResultItem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return SearchResult(items: items);
  }

  final List<SearchResultItem> items;
}
