import 'dart:async';

import 'package:flutter/material.dart';

enum Status { loading, success, failed }

@immutable
class Resource<T> {
  final Status status;
  final T? data;
  final String? message;
  final Exception? error;

  const Resource({this.data, required this.status, this.message, this.error});

  static Resource<T> loading<T>({T? data}) =>
      Resource<T>(data: data, status: Status.loading);

  static Resource<T> failed<T>({Exception? error, T? data}) =>
      Resource<T>(error: error, data: data, status: Status.failed);

  static Resource<T> success<T>({T? data}) =>
      Resource<T>(data: data, status: Status.success);

  static Future<Resource<T>> asFuture<T>(FutureOr<T> Function() req) async {
    try {
      final res = await req();
      return success<T>(data: res);
    } on Exception catch (e) {
      return Future.error(failed(error: e, data: null));
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Resource<T> &&
        other.status == status &&
        other.data == data &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode {
    return status.hashCode ^ data.hashCode ^ message.hashCode ^ error.hashCode;
  }
}
