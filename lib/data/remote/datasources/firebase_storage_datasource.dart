import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseStorageDataSource {
  FirebaseStorageDataSource(this._storage);
  final FirebaseStorage _storage;

  /// Uploads a file to a specific path and returns the download URL.
  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Uploads multiple files sequentially to prevent native crash on some platforms.
  Future<List<String>> uploadFiles(String basePath, List<File> files) async {
    final List<String> downloadUrls = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final path = '$basePath/${timestamp}_$i.jpg';
      final url = await uploadFile(path, file);
      downloadUrls.add(url);
    }
    
    return downloadUrls;
  }

  /// Deletes a file at a specific path.
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }
}
