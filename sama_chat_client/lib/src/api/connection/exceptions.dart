class ResponseException {
  int? status;
  String? message;

  ResponseException.fromJson(Map<String, dynamic> json)
      : status = int.tryParse(json['status']?.toString() ?? ''),
        message = json['message'].toString();

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
