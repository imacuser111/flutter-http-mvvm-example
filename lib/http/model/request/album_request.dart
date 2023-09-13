import 'dart:convert';

import 'api_request.dart';

// 取得Album
class FetchAlbumRequest extends APIRequest {
  final String title;

  FetchAlbumRequest(this.title);

  @override
  late String path = 'albums/$title';

  @override
  Method method = Method.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Object? get body => null;
}

// 創建Album
class CreateAlbumRequest with APIRequest {
  final String title;

  CreateAlbumRequest(this.title);

  @override
  String path = 'albums';

  @override
  Method method = Method.post;

  @override
  Object? get body => jsonEncode(<String, String>{
        'title': title,
      });
}
