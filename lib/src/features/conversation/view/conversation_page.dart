import 'dart:ui';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/api.dart' show TypingState;
import '../../../db/models/conversation_model.dart';
import '../../../navigation/constants.dart';
import '../../../repository/attachments/attachments_repository.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../../shared/connection/bloc/connection_bloc.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/connection/view/connection_title.dart';
import '../../../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../../shared/widget/typing_indicator.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/media_attachment/media_attachment_bloc.dart';
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
          conversationRepository:
              RepositoryProvider.of<ConversationRepository>(context),
          messagesRepository:
              RepositoryProvider.of<MessagesRepository>(context),
        ),
      ),
      BlocProvider(
          create: (context) => MediaAttachmentBloc(
              attachmentsRepository:
                  RepositoryProvider.of<AttachmentsRepository>(context))),
    ], child: const ConversationPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
        builder: (BuildContext context, state) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          centerTitle: false,
          titleSpacing: 0.0,
          title: ConnectionTitle(
            color: black,
            title: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: ListTile(
                onTap: () => _infoAction(context),
                title: Text(
                  overflow: TextOverflow.ellipsis,
                  state.conversation.name,
                  style: const TextStyle(
                      fontSize: 28.0, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                subtitle: _getSubtitle(state),
              ),
            ),
          ),
          actions: [_PopupMenuButton()],
        ),
        body: Column(
          children: [
            BlocListener<ConnectionBloc, ConnectionState>(
                listener: (context, state) {
                  if (state.status == ConnectionStatus.connected) {
                    BlocProvider.of<ConversationBloc>(context)
                        .add(const MessagesRequested(refresh: true));
                  }
                },
                child: const Flexible(child: MessagesList())),
            SafeArea(
                child: context.read<SharingIntentBloc>().state.status ==
                        SharingIntentStatus.processing
                    ? BlocListener<SendMessageBloc, SendMessageState>(
                        listener: (context, sendState) {
                          if (sendState.status == SendMessageStatus.success ||
                              sendState.status == SendMessageStatus.failure) {
                            context
                                .read<SharingIntentBloc>()
                                .add(SharingIntentCompleted());
                          }
                        },
                        child: ConnectionChecker(
                            child: MessageInput(
                                sharedText: context
                                    .read<SharingIntentBloc>()
                                    .state
                                    .sharedFiles
                                    .firstOrNull
                                    ?.path)),
                      )
                    : const MessageInput())
          ],
        ),
      );
    });
  }

  Widget _getSubtitle(ConversationState state) {
    var conversation = state.conversation;
    var participants = state.participants;
    var typing = state.typingStatus;
    String title = '';
    Color color = dullGray;
    var showTyping = typing?.typingState == TypingState.start;

    if (showTyping) {
      return TypingIndicator(
          userName:
              state.conversation.type == 'u' ? '' : getUserName(typing!.user));
    }
    if (conversation.type == 'u') {
      if (conversation.opponent?.recentActivity != null) {
        var date = DateTime.fromMillisecondsSinceEpoch(
                conversation.opponent!.recentActivity! * 1000)
            .toLocal();

        DateTime justNow = DateTime.now().subtract(const Duration(minutes: 1));

        String? suffix;
        if (conversation.opponent!.recentActivity! == 0) {
          color = green;
          title = 'online';
        } else if (!date.difference(justNow).isNegative) {
          suffix = 'just now';
        } else if (justNow.difference(date).inHours < 24) {
          suffix = DateFormat().addPattern('\'a\'t HH:mm').format(date);
          if (justNow.day != date.day) {
            suffix = 'yesterday $suffix';
          }
        } else if (justNow.difference(date).inDays < 4) {
          suffix = DateFormat().addPattern('E \'a\'t HH:mm').format(date);
        } else {
          suffix =
              DateFormat().addPattern('dd/MM/yyyy \'a\'t HH:mm').format(date);
        }
        if (suffix != null) title = 'Last seen $suffix';
      } else {
        title = 'Last seen recently';
      }
    } else {
      title = '${participants.length} members';
    }
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14.0, color: color),
    );
  }
}

enum _Menu { info, deleteAndLeave }

class _PopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Menu>(
        position: PopupMenuPosition.under,
        onSelected: (_Menu item) {
          switch (item) {
            case _Menu.info:
              _infoAction(context);
              break;
            case _Menu.deleteAndLeave:
              connectionChecker(
                  context,
                  () => showDialog(
                      context: context,
                      builder: (_) {
                        return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: AlertDialog(
                              title: const Text('Delete chat',
                                  style: TextStyle(fontSize: 20)),
                              content: const Text(
                                  'Do you want to delete this chat?',
                                  style: TextStyle(fontSize: 16)),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text("Ok"),
                                  onPressed: () {
                                    context
                                        .read<SendMessageBloc>()
                                        .add(const TextMessageClear());
                                    context
                                        .read<ConversationBloc>()
                                        .add(const ConversationDeleted());
                                  },
                                ),
                              ],
                            ));
                      }));
              break;
          }
        },
        icon: const Icon(
          Icons.more_vert_outlined,
          color: dullGray,
        ),
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<_Menu>>[
            const PopupMenuItem<_Menu>(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              value: _Menu.info,
              child: ListTile(
                leading: Icon(Icons.visibility_outlined),
                title: Text('Info'),
              ),
            ),
            const PopupMenuItem<_Menu>(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                value: _Menu.deleteAndLeave,
                child: ListTile(
                  leading: Icon(Icons.exit_to_app_outlined),
                  title: Text('Delete and leave'),
                ))
          ];
        });
  }
}

Future<void> _infoAction(BuildContext context) async {
  var state = context.read<ConversationBloc>().state;
  if (state.conversation.type == 'u') {
    context.push(userInfoPath, extra: state.conversation.opponent);
  } else {
    bool conversationUpdated =
        await context.push(groupInfoPath, extra: state.conversation) as bool;
    if (conversationUpdated && context.mounted) {
      context.read<ConversationBloc>().add(const ParticipantsReceived());
    }
  }
}
