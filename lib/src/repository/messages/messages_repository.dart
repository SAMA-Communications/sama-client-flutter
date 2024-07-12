import '../../api/api.dart' as api;
import '../../api/conversations/models/models.dart';

class MessagesRepository {
  Future<List<Message>> getMessages(
    String cid, {
    Map<String, dynamic>? parameters,
  }) async {
    return api.getMessages({'cid': cid, if (parameters != null) ...parameters});
  }
}
