import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/conversation/conversation_repository.dart';
import '../../../../repository/global_search/global_search_repository.dart';
import '../../../../repository/messages/messages_repository.dart';
import '../../../search/bloc/global_search_bloc.dart';
import '../../bloc/forward_message/forward_messages_bloc.dart';
import '../../models/chat_message.dart';
import 'forward_search_form.dart';

class ForwardMessagesWidget extends StatelessWidget {
  final Set<ChatMessage> forwardMessages;

  const ForwardMessagesWidget(this.forwardMessages, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GlobalSearchBloc>(
          create: (context) => GlobalSearchBloc(
            globalSearchRepository:
                RepositoryProvider.of<GlobalSearchRepository>(context),
          ),
        ),
        BlocProvider<ForwardMessagesBloc>(
          create: (context) => ForwardMessagesBloc(
            conversationRepository:
                RepositoryProvider.of<ConversationRepository>(context),
            messagesRepository:
                RepositoryProvider.of<MessagesRepository>(context),
          ),
        ),
      ],
      child: ForwardSearchForm(forwardMessages),
    );
  }
}
