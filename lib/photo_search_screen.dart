import 'package:flutter/material.dart';
import 'photo.dart';
import 'unsplash_service.dart';

class PhotoSearchScreen extends StatefulWidget {
  const PhotoSearchScreen({super.key});

  @override
  _PhotoSearchScreenState createState() => _PhotoSearchScreenState();
}

class _PhotoSearchScreenState extends State<PhotoSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final UnsplashService _unsplashService = UnsplashService();
  List<Photo> _photos = [];
  bool _isLoading = false;

  // Fungsi untuk memanggil pencarian
  void _searchPhotos() async {
    setState(() {
      _isLoading = true;
    });

    print('Mencari gambar dengan query: ${_controller.text}');

    try {
      final photos = await _unsplashService.searchPhotos(_controller.text);
      setState(() {
        _photos = photos;
        print('Berhasil mendapatkan ${photos.length} gambar');
      });
    } catch (e) {
      print('Gagal memuat gambar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallpaper Flutter',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search wallpapers',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPhotos(); // Panggil fungsi pencarian saat tombol search ditekan
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
              onSubmitted: (value) {
                _searchPhotos(); // Panggil fungsi pencarian saat Enter ditekan
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return GridTile(
                        footer: GridTileBar(
                          backgroundColor: Colors.black45,
                          title: Text(
                            photo.description ?? 'No Description',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(photo.user.name ?? 'Unknown'),
                        ),
                        child: Image.network(
                          photo.urls.regular,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
