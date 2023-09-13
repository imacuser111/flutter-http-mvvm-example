
import 'dart:convert';
import 'package:http/http.dart';
import 'podo/json.dart';

class ServerPack {
  final Response response;

  ServerPack(this.response);

  Album get album {
    return Album.fromJson(jsonDecode(response.body));
  }
}