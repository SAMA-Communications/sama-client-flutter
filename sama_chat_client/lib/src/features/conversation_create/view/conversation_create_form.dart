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
        appBar: const GlobalSearchBar(),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
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
                  SearchBody(searchType: SearchType.users)
                ]))
              ]),
        ));
  }
}
