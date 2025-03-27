import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../shared/secure_storage.dart';
import '../api.dart';

const unauthorizedTimeout = 5;

class SamaConnectionService {
  static final _instance = SamaConnectionService._();

  static SamaConnectionService get instance {
    return _instance;
  }

  Future<WebSocketChannel>? openConnectionFeature;
  WebSocketChannel? connection;

  Map<String, RequestInfo> awaitingRequests = {};

  final StreamController<ConnectionState> _connectionStateStreamController =
      StreamController.broadcast();

  Stream<ConnectionState> get connectionStateStream =>
      _connectionStateStreamController.stream;

  final StreamController<Map<String, dynamic>> _dataController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  ConnectionState _connectionState = ConnectionState.idle;

  ConnectionState get connectionState => _connectionState;

  SamaConnectionService._() {
    //fix for iOS https://github.com/flutter/flutter/issues/35272
    ConnectivityManager.instance.connectivityChangedStream.listen((_) {
      log('[SamaConnectionService][network connection changed]');
      if (connectionState != ConnectionState.failed) {
        _updateConnectionState(ConnectionState.failed);
      }
    });
  }

  Future<WebSocketChannel> connect() async {
    log(
      '[SamaConnectionService][connect]',
    );

    _updateConnectionState(ConnectionState.connecting);

    final wssUrl =
        Uri.parse('wss://${await SecureStorage.instance.getEnvironmentUrl()}');
    final channel = WebSocketChannel.connect(wssUrl);

    return channel.ready.then((_) {
      _updateConnectionState(ConnectionState.connected);

      channel.stream.listen(
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
          _updateConnectionState(ConnectionState.failed);
        },
        onDone: () {
          log('[SamaConnectionService][onDone]');
          _updateConnectionState(ConnectionState.failed);
        },
      );
      return channel;
    });
  }

  Future<WebSocketChannel> getConnection(
      {bool forciblyRecreateConnection = false}) {
    if (!forciblyRecreateConnection && openConnectionFeature != null) {
      return openConnectionFeature!;
    } else if (!forciblyRecreateConnection && connection != null) {
      return Future.value(connection);
    }

    openConnectionFeature = connect().then((channel) {
      connection = channel;
      return connection!;
    }).whenComplete(() {
      openConnectionFeature = null;
    });

    return openConnectionFeature!;
  }

  /// [requestData] should be represented as the List or Map object that can be encoded to the JSON object
  Future<Map<String, dynamic>> sendRequest(
    String requestName,
    dynamic requestData, {
    String? retryRequestId,
    Completer<Map<String, dynamic>>? retryCompleter,
    bool shouldRetry = true,
  }) {
    var requestId = retryRequestId ??= const Uuid().v4().toString();

    var requestCompleter = retryCompleter ??= Completer<Map<String, dynamic>>();

    awaitingRequests[requestId] = RequestInfo(
        name: requestName,
        data: requestData,
        completer: requestCompleter,
        shouldRetry: shouldRetry);

    var request = {
      'request': {
        requestName: requestData,
        'id': requestId,
      }
    };

    log('request', jsonData: request);

    getConnection().then((connection) {
      connection.sink.add(jsonEncode(request));
    }).catchError((onError) {
      _updateConnectionState(ConnectionState.failed);
      awaitingRequests.remove(requestId);
      if (onError is SocketException) {
        log('request', stringData: 'SocketException');
        requestCompleter.completeError(ResponseException.fromJson(
            {'status': -1, 'message': onError.message}));
      } else if (onError is WebSocketChannelException) {
        log('request', stringData: 'WebSocketChannelException');
        requestCompleter.completeError(ResponseException.fromJson(
            {'status': -1, 'message': onError.message}));
      } else {
        log('request', stringData: 'Exception: ${onError.toString()}');
        requestCompleter.completeError(ResponseException.fromJson({
          'status': -1,
          'message':
              'Unknown error happens. Please check internet connection and try again'
        }));
      }
    });

    return requestCompleter.future;
  }

  Future<bool> reconnect() {
    log('[SamaConnectionService][reconnect]');
    return getConnection(forciblyRecreateConnection: true).then((onValue) {
      log('[SamaConnectionService][reconnect]', stringData: 'reconnected');
      return true;
    }).catchError((exception) {
      log('[SamaConnectionService][reconnect]', stringData: 'reconnect failed');
      return false;
    });
  }

  closeConnection() {
    connection?.sink.close(status.normalClosure).then((_) {
      _updateConnectionState(ConnectionState.disconnected);

      connection = null;
    });
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

      if (jsonData['ask'] != null) {
        var response = jsonData['ask'];
        var responseId = response['mid'];
        var request = awaitingRequests.remove(responseId);
        if (request != null) request.completer.complete(response);
      }

      _dataController.add(jsonData);
    } catch (e) {
      log(
        '[SamaConnectionService][_processData]',
        stringData: 'data processing error: $e',
      );
    }
  }

  void _processResponse(Map<String, dynamic> response) {
    log(
      '[SamaConnectionService][_processResponse] response:',
      jsonData: response,
    );

    var responseId = response['id'];
    var error = response['error'];

    var requestInfo = awaitingRequests.remove(responseId);
    if (requestInfo != null) {
      var completer = requestInfo.completer;
      if (error != null) {
        var responseException = ResponseException.fromJson(error);//CHECK AFTER FIX https://connectycube-apps.atlassian.net/browse/FM-114
        if (responseException.status == HttpStatus.unauthorized) {
          print('Unauthorized wait to reconnect $unauthorizedTimeout seconds');
          //Unauthorized wait to reconnect
          awaitingRequests[responseId] = requestInfo;
          Future.delayed(const Duration(seconds: unauthorizedTimeout), () {
            if (awaitingRequests[responseId] != null) {
              print('Unauthorized completeError');
              awaitingRequests.remove(responseId);
              completer.completeError(responseException);
            }
          });
        } else {
          completer.completeError(responseException);
        }
      } else {
        completer.complete(response);
      }
    }
  }

  void _updateConnectionState(ConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateStreamController.add(state);
    }
  }

  void resendAwaitingRequests() {
    if (awaitingRequests.isNotEmpty) {
      Map.of(awaitingRequests).forEach((requestId, requestInfo) {
        if (requestInfo.shouldRetry) {
          sendRequest(
            requestInfo.name,
            requestInfo.data,
            retryRequestId: requestId,
            retryCompleter: requestInfo.completer,
          );
        }
      });
    }
  }
}

enum ConnectionState { idle, connecting, connected, disconnected, failed }

class RequestInfo {
  final String name;
  final dynamic data;
  final Completer<Map<String, dynamic>> completer;
  final bool shouldRetry;

  RequestInfo(
      {required this.name,
      required this.data,
      required this.completer,
      required this.shouldRetry});
}
