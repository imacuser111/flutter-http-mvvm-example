enum Method { get, post, put, delete }

abstract mixin class APIRequest {
  Method get method;

  String get path;

  Map<String, String>? get headers {
    return <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
  }

  Object? get body;
}