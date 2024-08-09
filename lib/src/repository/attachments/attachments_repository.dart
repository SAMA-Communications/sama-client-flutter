import '../../api/api.dart' as api;

class AttachmentsRepository {
  AttachmentsRepository();

  Future<Map<String, String>> getFilesUrls(Set<String> filesIds) {
    return api.getFilesUrls(filesIds);
  }
}
