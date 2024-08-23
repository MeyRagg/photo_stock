import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'archive_service.dart';
import 'photo.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final ArchiveService _archiveService = ArchiveService();
  List<Photo> _archivedPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArchivedPhotos();
  }

  Future<void> _loadArchivedPhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos = await _archiveService.getArchivedPhotos();
      setState(() {
        _archivedPhotos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load archived photos');
    }
  }

  Future<void> _unarchivePhoto(Photo photo) async {
    try {
      await _archiveService.removePhoto(photo);
      Fluttertoast.showToast(msg: 'Photo unarchived');
      _loadArchivedPhotos(); // Reload photos after unarchiving
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to unarchive photo: $e');
    }
  }

  Future<void> _refreshPhotos() async {
    _loadArchivedPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPhotos, // Button to reload the page
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPhotos,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _archivedPhotos.isEmpty
                ? const Center(child: Text('No archived photos'))
                : ListView.builder(
                    itemCount: _archivedPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = _archivedPhotos[index];
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _unarchivePhoto(photo),
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
