import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../search/view/search_bar.dart';
import '../../search/view/search_form.dart';

class ConversationCreateForm extends StatefulWidget {
  const ConversationCreateForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConversationCreateFormState();
  }
}

class ConversationCreateFormState extends State<ConversationCreateForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: black,
          iconTheme: const IconThemeData(
            color: white,
          ),
          title: const Text(
            'Create chat',
            style: TextStyle(color: white),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlobalSearchBar(),
                Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 16),
                      child: TextButton.icon(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(slateBlue),
                        ),
                        onPressed: () => context.push(groupCreateScreenPath),
                        icon: const Icon(Icons.group_outlined,
                            color: lightWhite, size: 25),
                        label: const Text(
                          'Create group',
                          style: TextStyle(
                              color: lightWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ]),
                const Expanded(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'List of users:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SearchForm(searchType: SearchType.both)
                ]))
              ]),
        ));
  }
}
