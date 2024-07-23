import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../api/api.dart';
import '../../../db/models/conversation.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/send_message/send_message_bloc.dart';
import 'message_input.dart';
import 'messages_list.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  static MultiBlocProvider route(Object? extra) {
    ConversationModel currentConversation = extra as ConversationModel;

    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) => ConversationBloc(
              currentConversation: currentConversation,
              conversationRepository:
                  RepositoryProvider.of<ConversationRepository>(context),
              messagesRepository:
                  RepositoryProvider.of<MessagesRepository>(context),
              userRepository: RepositoryProvider.of<UserRepository>(context))
            ..add(const MessagesRequested())),
      BlocProvider(
        create: (context) => SendMessageBloc(
          currentConversation: currentConversation,
          messagesRepository:
              RepositoryProvider.of<MessagesRepository>(context),
        ),
      ),
    ], child: const ConversationPage());
  }

  @override
  Widget build(BuildContext context) {
    var currentConversation =
        context.select((ConversationBloc bloc) => bloc.currentConversation);

    return BlocBuilder<ConversationBloc, ConversationState>(
        builder: (BuildContext context, state) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: ListTile(
              title: Text(
                overflow: TextOverflow.ellipsis,
                currentConversation.name ??
                    getUserName(currentConversation.opponent),
                style: const TextStyle(
                    fontSize: 28.0, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              subtitle: Text(
                _getSubtitle(currentConversation, state.participants),
                style: const TextStyle(fontSize: 14.0),
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert_outlined,
                  color: dullGray,
                ))
          ],
        ),
        body: Column(
          children: [
            const Flexible(child: MessagesList()),
            MessageInput(),
          ],
        ),
      );
    });
  }

  String _getSubtitle(
    ConversationModel conversation,
    Set<User> participants,
  ) {
    if (conversation.type == 'u') {
      if (conversation.opponent?.recentActivity != null) {
        var date = DateTime.fromMillisecondsSinceEpoch(
                conversation.opponent!.recentActivity! * 1000)
            .toLocal();

        DateTime justNow = DateTime.now().subtract(const Duration(minutes: 1));

        String suffix;

        if (!date.difference(justNow).isNegative) {
          suffix = 'just now';
        } else if (justNow.difference(date).inHours < 24) {
          suffix = DateFormat().addPattern('\'a\'t HH:MM').format(date);
        } else if (justNow.difference(date).inDays < 4) {
          suffix = DateFormat().addPattern('E \'a\'t HH:MM').format(date);
        } else {
          suffix =
              DateFormat().addPattern('dd/MM/yyyy \'a\'t HH:MM').format(date);
        }

        return 'Last seen $suffix';
      } else {
        return 'Last seen recently';
      }
    } else {
      return '${participants.length} members';
    }
  }
}
