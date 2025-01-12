import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../shared/secure_storage.dart';
import '../api.dart';

const _headers = {'Content-type': 'application/json'};

Future<Map<String, dynamic>> sendHTTPRequest(
    String requestName, dynamic requestData,
    [Map? requestHeaders]) async {
  final url = 'https://${await SecureStorage.instance.getEnvironmentUrl()}';
  var urlQuery = buildQueryUrl(url, [requestName]);
  var body = jsonEncode(requestData);
  Map<String, String> headers = Map.of(_headers);
  requestHeaders?.forEach((k, v) {
    headers[k] = v;
  });
  log('HTTP request', stringData: '$urlQuery $headers $body');

  Response response =
      await post(urlQuery, headers: headers, body: jsonEncode(requestData));

  print('HTTP response request headers ${response.request?.headers}');
  print('HTTP response statusCode ${response.statusCode}, headers $headers ${response.headers}');

  var completer = Completer<Map<String, dynamic>>();
  switch (response.statusCode) {
    case 200:
    case 201:
    case 202:
      Map<String, dynamic> data = jsonDecode(response.body);

      var cookie = response.headers['set-cookie'];
      if (cookie != null) {
        data['refreshToken'] = Cookie.fromSetCookieValue(cookie).value;
      }

      completer.complete(data);
      break;

    case 400:
    case 401:
    case 403:
    case 404:
    case 422:
    case 429:
    case 500:
    case 503:
      Map<String, dynamic> data = jsonDecode(response.body);
      completer.completeError(ResponseException.fromJson(data)); //TODO CHECK
      break;

    default:
      completer.completeError(ResponseException.fromJson(
          {'status': response.statusCode, 'message': response.reasonPhrase}));
  }
  log('HTTP response', jsonData: await completer.future);
  return completer.future;
}

Uri buildQueryUrl(String url, List<dynamic> specificParts) {
  StringBuffer stringBuffer = StringBuffer();
  stringBuffer.write(url);

  for (dynamic part in specificParts) {
    stringBuffer.write("/");
    stringBuffer.write(part.toString());
  }

  return Uri.parse(stringBuffer.toString());
}
