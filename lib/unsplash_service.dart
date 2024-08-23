import 'package:dio/dio.dart';

import 'photo.dart';

class UnsplashService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.unsplash.com';
  final String _accessKey = 'cZckWCVJsQhN5QJgPW3gSM28-32gO9Tfpp0f1I1aado';

  Future<List<Photo>> getRandomPhotos(int count) async {
    final response = await _dio.get(
      '$_baseUrl/photos/random',
      queryParameters: {'count': count},
      options: Options(
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Photo.fromJson(json)).toList();
  }

  Future<List<Photo>> searchPhotos(String query) async {
    final response = await _dio.get(
      '$_baseUrl/search/photos',
      queryParameters: {'query': query, 'per_page': 20},
      options: Options(
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ),
    );

    final List<dynamic> data = response.data['results'];
    return data.map((json) => Photo.fromJson(json)).toList();
  }
}
