import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../db/models/conversation_model.dart';
import '../../../../shared/ui/colors.dart';
import '../../../conversations_list/conversations_list.dart';
import '../../../search/bloc/global_search_bloc.dart';
import '../../../search/bloc/global_search_state.dart';
import '../../../search/view/search_bar.dart';
import '../../bloc/conversation_bloc.dart';
import '../../bloc/forward_message/forward_messages_bloc.dart';
import '../../models/chat_message.dart';

class ForwardSearchForm extends StatelessWidget {
  final List<ChatMessage> forwardMessages;

  const ForwardSearchForm(
    this.forwardMessages, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const GlobalSearchBar(withBack: false),
        _SearchBody(forwardMessages),
      ],
    );
  }
}

class _SearchBody extends StatelessWidget {
  final List<ChatMessage> forwardMessages;

  const _SearchBody(this.forwardMessages);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForwardMessagesBloc, ForwardMessagesState>(
      listener: (context, state) {
        switch (state.status) {
          case ForwardMessagesStatus.initial:
            break;
          case ForwardMessagesStatus.processing:
            break;
          case ForwardMessagesStatus.success:
            context.read<ConversationBloc>().add(const ChooseMessages(false));
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Forwarded successfully')),
              );
          case ForwardMessagesStatus.failure:
            context.read<ConversationBloc>().add(const ChooseMessages(false));
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '')),
              );
        }
      },
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          var chats = context.watch<ForwardMessagesBloc>().state.chats;
          return switch (state) {
            SearchStateEmpty() => chats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text('Please start typing to find chat'),
                  )
                : Expanded(child: _SearchResults(chats, forwardMessages)),
            SearchStateLoading() => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            SearchStateError() => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(state.error),
              ),
            SearchStateSuccess() => Expanded(
                child: _SearchResults(state.conversations, forwardMessages)),
          };
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<ConversationModel> chats;
  final List<ChatMessage> forwardMessages;

  const _SearchResults(this.chats, this.forwardMessages);

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.only(left: 18.0),
        width: double.maxFinite,
        color: gainsborough, //define the background color
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _emptyListText(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationList = chats.isEmpty
        ? _emptyListText('We couldn\'t find the specified chats')
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: chats.length,
            itemBuilder: (BuildContext context, int index) {
              final conversation = chats[index];
              return ConversationListItem(
                conversation: conversation,
                onTap: () {
                  print('onTap');
                  context
                      .read<ForwardMessagesBloc>()
                      .add(SendForwardMessage([conversation], forwardMessages));
                },
              );
            },
          );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        children: <Widget>[
          _header('Chats'),
          conversationList,
        ],
      ),
    );
  }
}
