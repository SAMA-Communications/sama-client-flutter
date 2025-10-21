import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/attachment_model.dart';

class AttachmentLocalDatasource {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<bool> updateAttachmentsLocal(List<AttachmentModel> items) async {
    print('updateAttachmentLocal= $items');
    try {
      return await _databaseService.updateAttachmentsLocal(items);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
