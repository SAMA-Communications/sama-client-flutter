import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../db/models/conversation_model.dart';
import '../../../db/models/user_model.dart';
import '../../../navigation/constants.dart';
import '../../../repository/attachments/attachments_repository.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/sharing/bloc/sharing_intent_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/screen_factor.dart';
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
              subtitle: Text(
                _getSubtitle(state.conversation, state.participants),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.0),
              ),
            ),
          ),
          actions: [_PopupMenuButton()],
        ),
        body: Column(
          children: [
            const Flexible(child: MessagesList()),
            Padding(
                //need extra space for safe area on ios
                padding: EdgeInsets.only(
                    bottom: Platform.isIOS && !keyboardIsOpen(context)
                        ? 16.0
                        : 0.0),
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
                        child: MessageInput(
                            sharedText: context
                                .read<SharingIntentBloc>()
                                .state
                                .sharedFiles
                                .firstOrNull
                                ?.path),
                      )
                    : MessageInput())
          ],
        ),
      );
    });
  }

  String _getSubtitle(
    ConversationModel conversation,
    Set<UserModel> participants,
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
          if (justNow.day != date.day) {
            suffix = 'yesterday $suffix';
          }
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

enum _Menu { info, deleteAndLeave }

class _PopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = context.read<ConversationBloc>().state;
    return PopupMenuButton<_Menu>(
        position: PopupMenuPosition.under,
        onSelected: (_Menu item) {
          switch (item) {
            case _Menu.info:
              _infoAction(context);
              break;
            case _Menu.deleteAndLeave:
              showDialog(
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
                                    .read<ConversationBloc>()
                                    .add(const ConversationDeleted());
                              },
                            ),
                          ],
                        ));
                  });
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
  var currentUserId = context.read<AuthenticationBloc>().state.userId;
  var state = context.read<ConversationBloc>().state;

  if (state.conversation.type == 'u') {
    var user =
        state.participants.firstWhere((user) => user.id != currentUserId);
    context.push(userInfoPath, extra: user);
  } else {
    bool conversationUpdated =
        await context.push(groupInfoPath, extra: state.conversation) as bool;
    if (conversationUpdated && context.mounted) {
      context.read<ConversationBloc>().add(const ParticipantsReceived());
    }
  }
}
