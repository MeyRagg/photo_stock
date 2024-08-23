import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'archive_service.dart';
import 'photo.dart';
import 'unsplash_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  final ArchiveService _archiveService = ArchiveService();
  final ScrollController _scrollController = ScrollController();
  final List<Photo> _photos = [];
  final List<Photo> _archivedPhotos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;

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
  }

  Future<void> _loadInitialPhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos = await _unsplashService.getRandomPhotos(5);
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos = await _unsplashService.getRandomPhotos(5);
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _searchPhotos() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _photos.clear();
      _hasSearched = true;
    });

    try {
      final photos =
          await _unsplashService.searchPhotos(_searchController.text);
      setState(() {
        _photos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _archivePhoto(Photo photo) async {
    if (_archivedPhotos.any((archivedPhoto) => archivedPhoto.id == photo.id)) {
      Fluttertoast.showToast(msg: 'Photo is already archived');
      return;
    }

    try {
      await _archiveService.savePhoto(photo);
      Fluttertoast.showToast(msg: 'Photo archived');
      _loadArchivedPhotos();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to archive photo: $e');
    }
  }

  Future<void> _unarchivePhoto(Photo photo) async {
    try {
      await _archiveService.removePhoto(photo);
      Fluttertoast.showToast(msg: 'Photo unarchived');
      _loadArchivedPhotos();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to unarchive photo: $e');
    }
  }

  Future<void> _loadArchivedPhotos() async {
    final photos = await _archiveService.getArchivedPhotos();
    setState(() {
      _archivedPhotos.clear();
      _archivedPhotos.addAll(photos);
    });
  }

  bool _isPhotoArchived(Photo photo) {
    return _archivedPhotos.any((archivedPhoto) => archivedPhoto.id == photo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: _hasSearched
            ? null
            : const Text(
                'PhotoStock',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 74, 135),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _hasSearched = false;
                  _searchController.clear();
                  _photos.clear();
                  _loadInitialPhotos();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _hasSearched = true;
              });
            },
          ),
        ],
        bottom: _hasSearched
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search wallpapers',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 238, 238, 238),
                    ),
                    onSubmitted: (query) {
                      _searchPhotos();
                    },
                  ),
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _photos.clear();
            _loadInitialPhotos();
          });
        },
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
                  trailing: IconButton(
                    icon: Icon(
                      _isPhotoArchived(photo)
                          ? Icons.remove_circle
                          : Icons.archive,
                      color: _isPhotoArchived(photo) ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (_isPhotoArchived(photo)) {
                        _unarchivePhoto(photo);
                      } else {
                        _archivePhoto(photo);
                      }
                    },
                  ),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
