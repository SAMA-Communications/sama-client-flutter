import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/config.dart';
import '../utils/logger.dart';
import 'exceptions.dart';

class SamaConnectionService {
  SamaConnectionService._();

  static final _instance = SamaConnectionService._();

  static SamaConnectionService get instance {
    return _instance;
  }

  Future<WebSocketChannel>? openConnectionFeature;
  WebSocketChannel? connection;
  Map<String, Completer<Map<String, dynamic>>> awaitingRequests = {};

  Future<WebSocketChannel> getConnection() async {
    if (openConnectionFeature != null) {
      return openConnectionFeature!;
    } else if (connection != null) {
      return Future.value(connection);
    }

    final wssUrl = Uri.parse(apiUrl);
    final channel = WebSocketChannel.connect(wssUrl);

    openConnectionFeature = channel.ready.then((_) {
      connection = channel;
      connection?.stream.listen(
        (data) {
          log(
            '[SamaConnectionService][onDataReceived]',
            stringData: data.toString(),
          );
          _processData(data.toString());
        },
        onError: (error) {
          log(
            '[SamaConnectionService][onErrorReceived]',
            stringData: error.toString(),
          );
          _processError(error);
        },
        onDone: () {
          log('[SamaConnectionService][onDone]');
        },
      );
      return channel;
    }).whenComplete(() {
      openConnectionFeature = null;
    });

    return openConnectionFeature!;
  }

  Future<Map<String, dynamic>> sendRequest(
      String requestName, Map<String, dynamic> requestData) {
    var requestId = const Uuid().v4().toString();

    var requestCompleter = Completer<Map<String, dynamic>>();
    awaitingRequests[requestId] = requestCompleter;

    var request = {
      'request': {
        requestName: requestData,
        'id': requestId,
      }
    };

    log('request', jsonData: request);

    getConnection().then((connection) {
      connection.sink.add(jsonEncode(request));
    });

    return requestCompleter.future;
  }

  closeConnection() {
    connection?.sink.close(status.goingAway);
  }

  void _processError(error) {
    log(
      '[SamaConnectionService][_processError]',
      stringData: error.toString(),
    );
  }

  void _processData(String data) {
    log(
      '[SamaConnectionService][_processData]',
      stringData: data,
    );

    try {
      var jsonData = jsonDecode(data);
      var response = jsonData['response'];

      if (response != null) {
        log('response', jsonData: jsonData);
        _processResponse(response);
        return;
      }

      // TODO VT process realtime packages
    } catch (e) {
      log(
        '[SamaConnectionService][_processData]',
        stringData: 'data processing error: $e',
      );
    }
  }

  void _processResponse(Map<String, dynamic> response) {
    log(
      '[SamaConnectionService][_processData] response:',
      jsonData: response,
    );

    var responseId = response['id'];
    var error = response['error'];

    var completer = awaitingRequests.remove(responseId);
    if (completer != null) {
      if (error != null) {
        completer.completeError(ResponseException.fromJson(error));
      } else {
        completer.complete(response);
      }
    }
  }
}
