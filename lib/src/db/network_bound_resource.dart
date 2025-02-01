import 'dart:async';

import 'resource.dart';

class NetworkBoundResources<ResultType, RequestType> {
  Future<Resource<ResultType>> asFuture({
    required Future<ResultType> Function() loadFromDb,
    required bool Function(ResultType? data) shouldFetch,
    required Future<RequestType> Function() createCall,
    ResultType Function(RequestType result)? processResponse,
    required Future Function(RequestType item)? saveCallResult,
  }) {
    assert(
      RequestType == ResultType ||
          (!(RequestType == ResultType) && processResponse != null),
      "You need to specify the `processResponse` when the types are different",
    );
    processResponse ??= (value) => value as ResultType;
    return Resource.asFuture<ResultType>(() async {
      var value = await loadFromDb();

      if (shouldFetch(value)) {
        await _updateFromNetwork(createCall, saveCallResult, value);
        value = await loadFromDb();
      }

      return value;
    });
  }

  Future<void> _updateFromNetwork(
      Future<RequestType> Function() createCall,
      Future Function(RequestType item)? saveCallResult,
      ResultType? unconfirmedResult) async {
    return await createCall().then((value) async {
      if (value != unconfirmedResult) {
        if (saveCallResult != null) await saveCallResult(value);
      }
    });
  }
}

// class NetworkBoundResource<ResultType, RequestType> {
//   late StreamController<Resource<ResultType>> _result;
//
//   Stream<Resource<ResultType>> asStream({
//     required Stream<ResultType> loadFromDb(),
//     required bool shouldFetch(ResultType data),
//     required Future<RequestType> createCall(),
//     required ResultType processResponse(RequestType result),
//     required Future saveCallResult(RequestType item),
//   }) {
//     _result = StreamController<Resource<ResultType>>();
//
//     print("Call loading...");
//
//     _result.sink.add(Resource.loading());
//
//     _result.addStream(loadFromDb().transform(
//         StreamTransformer<ResultType, Resource<ResultType>>.fromHandlers(
//             handleData: (event, sink) async {
//       if (shouldFetch(event)) {
//         print("Fetch data and call loading");
//
//         sink.add(Resource.loading(data: event));
//
//         try {
//           var result = await _fetchFromNetwork(createCall, saveCallResult, event);
//           print("Fetching success");
//           await saveCallResult(result);
//           sink.add(Resource.success(data: event));
//         } on Exception catch (e) {
//           print("Fetching failed");
//           sink.addError(Resource.failed(data: null, error: e));
//         }
//       } else {
//         print("Fetching data its not necessary");
//         sink.add(Resource.success(data: event));
//       }
//     })));
//
//     return _result.stream;
//   }
//
// Future<RequestType> _fetchFromNetwork(
//     Future<RequestType> Function() createCall,
//     Future Function(RequestType item) saveCallResult,
//     ResultType unconfirmedResult) async {
//   saveCallResult(unconfirmedResult as RequestType);
//   return await createCall().then((value) async {
//     if(value != unconfirmedResult) {
//       await saveCallResult(value);
//     }
//     return value;
//   });
// }
//
// }
