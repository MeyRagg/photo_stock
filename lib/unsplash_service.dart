import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'photo.dart';

class UnsplashService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.unsplash.com';
  final String _accessKey =
      'cZckWCVJsQhN5QJgPW3gSM28-32gO9Tfpp0f1I1aado'; 

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
      queryParameters: {
        'query': query,
        'per_page': 30,
      },
      options: Options(
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ),
    );

    final data = response.data['results'] as List<dynamic>;
    return data.map((json) => Photo.fromJson(json)).toList();
  }

Future<String> downloadPhoto(Photo photo) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final path = '${directory.path}/${photo.id}.jpg';

        try {
          // Menambahkan log di sini
          print('Downloading from ${photo.urls.full} to $path');

          final response = await _dio.download(photo.urls.full, path);
          print('Download response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            return path; // Mengembalikan path file jika berhasil
          } else {
            throw Exception('Failed to download photo: ${response.statusCode}');
          }
        } catch (e) {
          print('Download exception: $e');
          throw Exception('Failed to download photo: $e');
        }
      } else {
        throw Exception('Failed to get external storage directory');
      }
    } else {
      throw Exception('Storage permission not granted');
    }
  }
}
