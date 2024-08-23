import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'photo.dart';

class ArchiveService {
  Future<void> savePhoto(Photo photo) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? archivedPhotos = prefs.getStringList('archivedPhotos');
    final updatedPhotos = archivedPhotos ?? [];
    updatedPhotos.add(jsonEncode(photo.toJson()));
    await prefs.setStringList('archivedPhotos', updatedPhotos);
  }

  Future<void> removePhoto(Photo photo) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? archivedPhotos = prefs.getStringList('archivedPhotos');
    if (archivedPhotos != null) {
      final updatedPhotos = archivedPhotos
          .where((jsonString) =>
              Photo.fromJson(jsonDecode(jsonString)).id != photo.id)
          .toList();
      await prefs.setStringList('archivedPhotos', updatedPhotos);
    }
  }

  Future<List<Photo>> getArchivedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? archivedPhotos = prefs.getStringList('archivedPhotos');
    if (archivedPhotos == null) {
      return [];
    } else {
      return archivedPhotos
          .map((jsonString) => Photo.fromJson(jsonDecode(jsonString)))
          .toList();
    }
  }
}
