import 'package:flutter/material.dart';

import 'photo.dart';
import 'unsplash_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  final TextEditingController _searchController = TextEditingController();
  final List<Photo> _photos = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadInitialPhotos();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _hasSearched ? null : const Text('Main Screen'),
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
                preferredSize:
                    const Size.fromHeight(56.0), // Tinggi disesuaikan
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
                      fillColor: Colors.grey[200],
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
