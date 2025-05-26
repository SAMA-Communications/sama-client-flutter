import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart';

import '../../shared/secure_storage.dart';
import '../api.dart';

const _headers = {HttpHeaders.contentTypeHeader: 'application/json'};

Future<Map<String, dynamic>> sendHTTPRequest(
    String url, String requestName, dynamic requestData,
    [Map? requestHeaders]) async {
  var urlQuery = buildQueryUrl(url, [requestName]);
  var body = jsonEncode(requestData);
  Map<String, String> headers = Map.of(_headers);
  requestHeaders?.forEach((k, v) {
    headers[k] = v;
  });

  log('HTTP request', stringData: '$urlQuery $headers $body');
  Response? response;
  try {
    response = await post(urlQuery, headers: headers, body: body);
  } catch (e) {
    print('response e = ${e}');
  }
  log('HTTP response statusCode ${response!.statusCode}, headers $headers ${response.headers}');

  var completer = Completer<Map<String, dynamic>>();
  switch (response.statusCode) {
    case 200:
    case 201:
    case 202:
      Map<String, dynamic> data = jsonDecode(response.body);

      var cookie = response.headers['set-cookie'];
      if (cookie != null) {
        data['refresh_token'] = Cookie.fromSetCookieValue(cookie).value;
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
      String message;
      try {
        message = jsonDecode(response.body);
      } catch (e) {
        message = response.body;
      }
      completer.completeError(ResponseException.fromJson(
          {'status': response.statusCode, 'message': message}));
      break;

    default:
      completer.completeError(ResponseException.fromJson(
          {'status': response.statusCode, 'message': 'unexpected error'}));
  }
  log('HTTP response', jsonData: await completer.future);
  return completer.future;
}

Future<Map<String, dynamic>> sendSamaHTTPRequest(
    String requestName, dynamic requestData,
    [Map? requestHeaders]) async {
  final url = 'https://${await SecureStorage.instance.getEnvironmentUrl()}';
  final orgId = await SecureStorage.instance.getEnvironmentOrgId();
  requestData['organization_id'] = orgId;

  return sendHTTPRequest(url, requestName, requestData, requestHeaders);
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

Future<void> applyHTTPCert() async {
  ByteData data =
      await rootBundle.load('assets/certificate.connectycube.com.pem');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
}
