import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'photo.dart';
import 'unsplash_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  final ScrollController _scrollController = ScrollController();
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialPhotos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMorePhotos();
      }
    });
    FlutterDownloader.initialize(); // Initialize FlutterDownloader
  }

  Future<void> _loadInitialPhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos =
          await _unsplashService.getRandomPhotos(5); // Ambil 5 foto acak
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle the error here
    }
  }

  Future<void> _loadMorePhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos =
          await _unsplashService.getRandomPhotos(5); // Ambil 5 foto acak
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      // Handle the error here
    }
  }

  Future<void> _searchPhotos(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _photos.clear(); // Hapus foto yang ada
    });

    try {
      final photos = await _unsplashService.searchPhotos(query);
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle the error here
    }
  }

  Future<void> _downloadPhoto(Photo photo) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: photo.urls.full,
        savedDir: (await getExternalStorageDirectory())!.path,
        fileName: '${photo.id}.jpg',
        showNotification: true,
        openFileFromNotification: true,
      );
      Fluttertoast.showToast(msg: 'Download started with task ID: $taskId');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to download photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Photo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchPhotos(_searchController.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search photos',
              ),
              onSubmitted: (query) {
                _searchPhotos(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _photos.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final photo = _photos[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      photo.urls.regular,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                    ListTile(
                      title: Text(photo.description ?? 'No Description'),
                      subtitle: Text(photo.user.name ?? 'Unknown'),
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://example.com/user-profile.jpg'), // Use user's profile image URL if available
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadPhoto(photo),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
