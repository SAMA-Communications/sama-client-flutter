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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlobalSearchBar(hintText: 'Search name or user'),
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
                            'New group',
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
                      child: Align(
                          alignment: AlignmentGeometry.topCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: SearchForm(searchType: SearchType.both),
                          )))
                ])));
  }
}
