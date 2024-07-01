import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  final StreamController<ConnectionState> _connectionStateStreamController =
      StreamController.broadcast();

  Stream<ConnectionState> get connectionStateStream =>
      _connectionStateStreamController.stream;

  ConnectionState _connectionState = ConnectionState.idle;

  ConnectionState get connectionState => _connectionState;

  Future<WebSocketChannel> connect() {
    log(
      '[SamaConnectionService][connect]',
    );

    _updateConnectionState(ConnectionState.connecting);

    final wssUrl = Uri.parse(apiUrl);
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
      {bool forciblyRecreateConnection = false}) async {
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
    }).catchError((onError) {
      if (onError is SocketException) {
        log('request', stringData: 'SocketException');
        requestCompleter.completeError(ResponseException.fromJson(
            {'status': -1, 'message': onError.message}));
      } else if (onError is WebSocketChannelException) {
        log('request', stringData: 'WebSocketChannelException');
        requestCompleter.completeError(ResponseException.fromJson(
            {'status': -1, 'message': onError.message}));
      } else {
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
    connection?.sink.close(status.goingAway).then((_) {
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

  void _updateConnectionState(ConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateStreamController.add(state);
    }
  }
}

enum ConnectionState { idle, connecting, connected, disconnected, failed }
