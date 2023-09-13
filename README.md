---
title: 'Flutter HTTP'
tags: Flutter
disqus: hackmd
---

<font size="6">Flutter HTTP</font>

 ## 添加http包
 
 ```shell=
flutter pub add http
```

Import the http package.

```dart=
import 'package:http/http.dart' as http;
```

Additionally, in your AndroidManifest.xml file, add the Internet permission.

```dart=
<!-- Required to fetch data from the internet. -->
<uses-permission android:name="android.permission.INTERNET" />
```

## 創建Model

```dart=
class Album {
  final int? userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
```

## 進行網路請求，並將http.Response轉換成Album Model

```dart=
// Get
Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

// Post
Future<Album> createAlbum(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

// Put
Future<Album> updateAlbum(String title) async {
  final response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update album.');
  }
}

// Delete
Future<Album> deleteAlbum(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON. After deleting,
    // you'll get an empty JSON `{}` response.
    // Don't return `null`, otherwise `snapshot.hasData`
    // will always return false on `FutureBuilder`.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a "200 OK response",
    // then throw an exception.
    throw Exception('Failed to delete album.');
  }
}
```

## 發送

```dart=
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    TextField(
      controller: _controller,
      decoration: const InputDecoration(hintText: 'Enter Title'),
    ),
    ElevatedButton(
      onPressed: () {
        setState(() {
          _futureAlbum = createAlbum(_controller.text);
        });
      },
      child: const Text('Create Data'),
    ),
  ],
)
```

## 加載到螢幕中

```dart=
FutureBuilder<Album>(
  future: _futureAlbum,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(snapshot.data!.title);
    } else if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }

    return const CircularProgressIndicator();
  },
)
```



---
title: 'Flutter MVVM'
tags: Flutter
disqus: hackmd
---

## MVVM

這邊用Http範例來實作MVVM架構

### Mdoel

- json.dart

```dart=
// Response
class Album {
  final int? userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
```

- api_response.dart

```dart=
class ApiResponse<T> {
  Status status;
  T? data;
  String? message;

  ApiResponse.initial(this.message) : status = Status.initial;

  ApiResponse.loading(this.message) : status = Status.loading;

  ApiResponse.completed(this.data) : status = Status.completed;

  ApiResponse.error(this.message) : status = Status.error;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { initial, loading, completed, error }
```

### ViewMode

- album_provider.dart

```dart=
class AlbumProvider with ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  ApiResponse get response {
    return _apiResponse;
  }

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
```

### View

- main.dart

```dart=
class HomeScreen extends StatelessWidget {
  final _controller = TextEditingController();

  /// Constructs a [HomeScreen]
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen build');

    final viewModel = Provider.of<AlbumProvider>(context, listen: false);

    // 等待畫面初始化完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchAlbumData('1');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Enter Title'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                viewModel.createAlbumData(_controller.text);
              },
              child: const Text('send createAlbumRequest'),
            ),
            Consumer<AlbumProvider>(
              builder: (context, value, child) {
                
                debugPrint(value.response.status.toString()); // print
                
                switch (value.response.status) {
                  case Status.error:
                    return const FlutterLogo();
                  case Status.completed:
                    Album data = value.response.data;
                    return Text(data.title);
                  default:
                    return const CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
```

## Demo

https://github.com/imacuser111/flutter-http-mvvm-example

