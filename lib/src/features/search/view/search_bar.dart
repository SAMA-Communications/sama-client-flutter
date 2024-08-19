import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/colors.dart';
import '../bloc/global_search_bloc.dart';
import '../bloc/global_search_event.dart';

class GlobalSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const GlobalSearchBar({super.key});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
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
      backgroundColor: black,
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
            if (text.length >= 2) {
              _globalSearchBloc.add(
                TextChanged(text: text),
              );
            }
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
    if (_textController.text.isNotEmpty) {
      _textController.text = '';
      _globalSearchBloc.add(const TextChanged(text: ''));
    } else {
      context.pop();
    }
  }
}
