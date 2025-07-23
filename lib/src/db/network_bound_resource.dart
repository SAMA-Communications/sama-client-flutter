import 'dart:async';

import 'resource.dart';

class NetworkBoundResources<ResultType, RequestType> {
  Future<Resource<ResultType>> asFuture({
    required Future<RequestType> Function() loadFromDb,
    required bool Function(RequestType? data, RequestType? slice) shouldFetch,
    Future<RequestType> Function()? createCallSlice,
    required Future<RequestType> Function() createCall,
    Future<ResultType> Function(RequestType result)? processResponse,
    required Future Function(RequestType item)? saveCallResult,
  }) {
    assert(
      RequestType == ResultType ||
          (!(RequestType == ResultType) && processResponse != null),
      "You need to specify the `processResponse` when the types are different",
    );

    return Resource.asFuture<ResultType>(() async {
      var value = await loadFromDb();
      var mustFetch = value is List ? value.isEmpty : false;
      if (mustFetch ||
          shouldFetch(value,
              createCallSlice != null ? await createCallSlice() : null)) {
        await _fetchFromNetwork(createCall, saveCallResult, value);
        value = await loadFromDb();
      }

      return processResponse != null
          ? await processResponse(value)
          : value as ResultType;
    });
  }

  late StreamController<Resource<ResultType>> _result;

  Stream<Resource<ResultType>> asStream({
    required Future<ResultType> Function() loadFromDb,
    required bool Function(ResultType? data) shouldFetch,
    required Future<RequestType> Function() createCall,
    ResultType Function(ResultType result)? processResponse,
    required Future Function(RequestType item)? saveCallResult,
  }) {
    _result = StreamController<Resource<ResultType>>();

    print("Call loading...");

    _result.sink.add(Resource.loading());

    _result.addStream(loadFromDb().asStream().transform(
        StreamTransformer<ResultType, Resource<ResultType>>.fromHandlers(
            handleData: (event, sink) async {
      if (shouldFetch(event)) {
        print("Fetch data and call loading");

        sink.add(Resource.loading(data: event));

        try {
          await _fetchFromNetwork(
              createCall, saveCallResult, event as RequestType);
          print("Fetching success");
          var value = await loadFromDb();
          sink.add(Resource.success(data: value));
        } on Exception catch (e) {
          print("Fetching failed");
          sink.addError(Resource.failed(data: null, error: e));
        }
      } else {
        print("Fetching data its not necessary");
        sink.add(Resource.success(data: event));
      }
    })));

    return _result.stream;
  }

  Future<void> _fetchFromNetwork(
      Future<RequestType> Function() createCall,
      Future Function(RequestType item)? saveCallResult,
      RequestType? unconfirmedResult) async {
    return await createCall().then((value) async {
      if (value != unconfirmedResult) {
        if (saveCallResult != null) await saveCallResult(value);
      }
    });
  }
}
