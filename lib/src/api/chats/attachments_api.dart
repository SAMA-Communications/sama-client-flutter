import 'package:sama_client_flutter/src/api/api.dart';

const String getFileUrlsRequestName = 'get_file_urls';

Future<Map<String, String>> getFilesUrls(Set<String> filesIds) {
  return SamaConnectionService.instance.sendRequest(
      getFileUrlsRequestName, {'file_ids': filesIds.toList()}).then((response) {
    return Map.of(response['file_urls'])
        .map((key, value) => MapEntry(key, value.toString()));
  });
}
