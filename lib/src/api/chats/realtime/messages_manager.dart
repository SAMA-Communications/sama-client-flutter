import 'dart:async';

import '../../connection/connection.dart';
import '../../conversations/models/models.dart';
import 'models/models.dart';

class MessagesManager {
  MessagesManager._() {
    _init();
  }

  static final _instance = MessagesManager._();

  static MessagesManager get instance {
    return _instance;
  }

  StreamSubscription<Map<String, dynamic>>? dataListener;

  final StreamController<Message> _incomingMessagesController =
      StreamController.broadcast();

  Stream<Message> get incomingMessagesStream =>
      _incomingMessagesController.stream;

  final StreamController<SystemChatMessage> _systemChatMessagesController =
      StreamController.broadcast();

  Stream<SystemChatMessage> get systemChatMessagesStream =>
      _systemChatMessagesController.stream;

  final StreamController<SentMessageStatus> _sentMessageStatusController =
      StreamController.broadcast();

  Stream<SentMessageStatus> get sentMessageStatusStream =>
      _sentMessageStatusController.stream;

  final StreamController<ReadMessagesStatus> _readMessagesStatusController =
      StreamController.broadcast();

  Stream<ReadMessagesStatus> get readMessagesStatusStream =>
      _readMessagesStatusController.stream;

  final StreamController<EditMessageStatus> _editMessageStatusController =
      StreamController.broadcast();

  Stream<EditMessageStatus> get editMessageStatusStream =>
      _editMessageStatusController.stream;

  final StreamController<DeleteMessagesStatus>
      _deletedMessagesStatusController = StreamController.broadcast();

  Stream<DeleteMessagesStatus> get deletedMessageStatusStream =>
      _deletedMessagesStatusController.stream;

  _init() {
    if (dataListener != null) return;

    dataListener = SamaConnectionService.instance.dataStream.listen((data) {
      if (data['message'] != null) {
        _processIncomingMessage(data['message']);
      } else if (data['ask'] != null) {
        _processSentMessagePackage(data['ask']);
      } else if (data['message_edit'] != null) {
        _processEditMessagePackage(data['message_edit']);
      } else if (data['message_read'] != null) {
        _processReadMessagePackage(data['message_read']);
      } else if (data['message_delete'] != null) {
        _processDeleteMessagePackage(data['message_delete']);
      } else if (data['system_message'] != null) {
        _processSystemMessagePackage(data['system_message']);
      }
    });
  }

  destroy() {
    dataListener?.cancel();
    dataListener = null;
  }

  void _processIncomingMessage(Map<String, dynamic> data) {
    var incomingMessage = Message.fromJson(data);

    _incomingMessagesController.add(incomingMessage);
  }

  void _processSentMessagePackage(Map<String, dynamic> data) {
    var sentMessageStatus = SentMessageStatus.fromJson(data);

    _sentMessageStatusController.add(sentMessageStatus);
  }

  void _processEditMessagePackage(Map<String, dynamic> data) {
    var editMessageStatus = EditMessageStatus.fromJson(data);

    _editMessageStatusController.add(editMessageStatus);
  }

  void _processReadMessagePackage(Map<String, dynamic> data) {
    var readMessageStatus = ReadMessagesStatus.fromJson(data);

    _readMessagesStatusController.add(readMessageStatus);
  }

  void _processDeleteMessagePackage(Map<String, dynamic> data) {
    var deletedMessagesStatus = DeleteMessagesStatus.fromJson(data);

    _deletedMessagesStatusController.add(deletedMessagesStatus);
  }

  void _processSystemMessagePackage(Map<String, dynamic> data) {
    if (data['x'] != null) {
      //RP check without != null - just if(data['x'])
      var systemMessage = SystemChatMessage.fromJson(data['x']);
      _systemChatMessagesController.add(systemMessage);
    }
  }
}
