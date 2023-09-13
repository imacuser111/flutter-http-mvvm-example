import 'package:flutter/cupertino.dart';

import '../../http_service.dart';
import '../../model/apis/api_response.dart';
import '../../model/request/album_request.dart';
import '../../model/request/api_request.dart';
import '../../model/response/podo/json.dart';

class AlbumProvider with ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  // Album? _album;

  ApiResponse get response {
    return _apiResponse;
  }

  // Album? get album {
  //   return _album;
  // }

  fetchAlbumData(String title) {
    APIRequest apiRequest = FetchAlbumRequest(title);
    decodeJson(apiRequest);
  }

  createAlbumData(String title) {
    APIRequest apiRequest = CreateAlbumRequest(title);
    decodeJson(apiRequest);
  }

  decodeJson(APIRequest apiRequest) async {
    _apiResponse = ApiResponse.loading('Create album data');
    notifyListeners();

    try {
      dynamic json = await HttpService().send(apiRequest);

      final album = Album.fromJson(json);

      _apiResponse = ApiResponse.completed(album);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      debugPrint(e.toString());
    }
    notifyListeners();
  }
}
