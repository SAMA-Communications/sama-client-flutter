import '../../api/api.dart' as api;
import '../../db/local/attachment_local_datasource.dart';
import '../../db/models/attachment_model.dart';

class AttachmentsRepository {
  final AttachmentLocalDatasource localDatasource;

  AttachmentsRepository(this.localDatasource);

  Future<Map<String, String>> getFilesUrls(Set<String> filesIds) {
    return api.getFilesUrls(filesIds);
  }

  Future<void> updateAttachmentsLocal(List<AttachmentModel> attachments) async {
    await localDatasource.updateAttachmentsLocal(attachments);
  }
}
