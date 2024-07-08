import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui/colors.dart';
import '../bloc/global_search_bloc.dart';
import '../bloc/global_search_event.dart';
import '../bloc/global_search_state.dart';
import '../models/search_result_item.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(),
        _SearchBody(),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  late GlobalSearchBloc _globalSearchBloc;

  @override
  void initState() {
    super.initState();
    _globalSearchBloc = context.read<GlobalSearchBloc>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      // titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(
          'assets/images/vector_logo.png',
          width: 32,
          fit: BoxFit.cover,
        ),
        onPressed: () {},
      ),
      title: SizedBox(
        height: kToolbarHeight - 18,
        child: TextField(
          controller: _textController,
          autocorrect: false,
          onChanged: (text) {
            _globalSearchBloc.add(
              TextChanged(text: text),
            );
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: white,
            contentPadding: const EdgeInsets.only(top: 14.0),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: GestureDetector(
              onTap: _onClearTapped,
              child: const Icon(Icons.clear),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: 'Search',
          ),
        ),
      ),
        centerTitle: false,
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _globalSearchBloc.add(const TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const Text('Please enter a term to begin'),
          SearchStateLoading() => const CircularProgressIndicator.adaptive(),
          SearchStateError() => Text(state.error),
          SearchStateSuccess() => state.items.isEmpty
              ? const Text('No Results')
              : Expanded(child: _SearchResults(items: state.items)),
        };
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.items});

  final List<SearchResultItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.item});

  final SearchResultItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: CircleAvatar(
      //   child: Image.network(item.owner.avatarUrl),
      // ),
      title: Text("item.fullName"),
      // onTap: () => launchUrl(Uri.parse(item.htmlUrl)),
    );
  }
}
