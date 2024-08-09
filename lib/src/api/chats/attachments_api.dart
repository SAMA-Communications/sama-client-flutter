import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../api.dart';

const String getFileUrlsRequestName = 'get_file_urls';
const String createFilesRequestName = 'create_files';

Future<Map<String, String>> getFilesUrls(Set<String> filesIds) {
  return SamaConnectionService.instance.sendRequest(
      getFileUrlsRequestName, {'file_ids': filesIds.toList()}).then((response) {
    return Map.of(response['file_urls'])
        .map((key, value) => MapEntry(key, value.toString()));
  });
}

Future<List<Attachment>> uploadFiles(List<File> files,
    Function(String fileName, int progtess)? onProgress) async {
  Completer<List<Attachment>> completer = Completer<List<Attachment>>();
  List<Attachment> resultAttachments = [];

  List<Map<String, dynamic>> requestData = files.map((file) {
    return {
      'name': basename(file.path),
      'size': file.lengthSync(),
      'content_type': lookupMimeType(file.path),
    };
  }).toList();

  await SamaConnectionService.instance
      .sendRequest(createFilesRequestName, jsonDecode(jsonEncode(requestData)))
      .then((response) async {
    List<Map<String, dynamic>> rawFiles = List.of(response['files'])
        .map((rawFile) => Map<String, dynamic>.of(rawFile))
        .toList();

    List<Future<StreamedResponse>> apiRequests = [];

    for (var rawFile in rawFiles) {
      var uri = Uri.tryParse(rawFile['upload_url']);

      var fileName = rawFile['name'];

      var file =
          files.where((file) => basename(file.path) == fileName).firstOrNull;

      var fileId = rawFile['object_id'];
      var contentType = rawFile['content_type'];
      var contentLength = rawFile['size'];

      if (file != null && uri != null) {
        ByteStream stream = ByteStream(file.openRead());

        Map<String, String> headers = {
          'Content-Length': contentLength.toString(),
          'Content-Type': contentType,
        };

        var request = StreamedRequestProgressed(
          'PUT',
          uri,
          fileName: fileName,
          onProgress: (fileName, progress) {
            onProgress?.call(fileName, progress);
          },
        )
          ..headers.addAll(headers)
          ..contentLength = contentLength;

        request.sink.addStream(stream).then((_) async {
          await request.sink.close();
        });

        apiRequests.add(request.send());
        resultAttachments.add(Attachment(fileId: fileId, fileName: fileName));
      }
    }
    await Future.wait(apiRequests).then((responses) {
      var errorResult = responses
          .where((response) =>
              response.statusCode != 200 && response.statusCode != 201)
          .firstOrNull;
      if (errorResult != null) {
        completer.completeError(ResponseException.fromJson({
          'status': errorResult.statusCode,
          'message': 'Failed to load one or more files'
        }));
      } else {
        completer.complete(resultAttachments);
      }
    }).catchError((onError) {
      completer.completeError(ResponseException.fromJson(
          {'status': -1, 'message': onError.toString()}));
    });
  }).catchError((onError) {
    if (onError is ResponseException) {
      completer.completeError(onError);
    } else {
      completer.completeError(ResponseException.fromJson(
          {'status': -1, 'message': onError.toString()}));
    }
  });

  return completer.future;
}

class StreamedRequestProgressed extends StreamedRequest {
  StreamedRequestProgressed(
    super.method,
    super.url, {
    required this.fileName,
    this.onProgress,
  });

  final String fileName;
  final void Function(String fileName, int progtess)? onProgress;

  @override
  ByteStream finalize() {
    final ByteStream byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final int total = contentLength!;
    int bytes = 0;
    int progress = 0;

    final streamTransformer = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        final int newProgress = ((bytes / total) * 100).toInt();
        if (newProgress != progress) {
          onProgress?.call(fileName, newProgress);
        }
        progress = newProgress;

        sink.add(data);
      },
    );

    final Stream<List<int>> stream = byteStream.transform(streamTransformer);

    return ByteStream(stream);
  }
}
