import 'dart:convert';

import 'package:http/http.dart';

import 'package:http/http.dart' as http;

import 'model/request/api_request.dart';

class HttpService {
  final _baseUrl = "https://jsonplaceholder.typicode.com/";

  Future<dynamic> send(APIRequest request) async {
    Response response;

    Uri url = Uri.parse(_baseUrl + request.path);
    switch (request.method) {
      case Method.get:
        response = await http.get(url, headers: request.headers);
      case Method.post:
        response =
            await http.post(url, headers: request.headers, body: request.body);
      case Method.put:
        response =
            await http.put(url, headers: request.headers, body: request.body);
      case Method.delete:
        response = await http.delete(url,
            headers: request.headers, body: request.body);
    }
    try {
      return switch (response.statusCode) {
        >= 200 && < 300 => jsonDecode(response.body),
        _ => throw Error()
      };
    } catch (error) {
      throw Error();
    }
  }
}
