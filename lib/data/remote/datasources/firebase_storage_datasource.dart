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

  /// Uploads multiple files in parallel and returns their download URLs.
  Future<List<String>> uploadFiles(String basePath, List<File> files) async {
    final futures = files.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$basePath/${timestamp}_$index.jpg';
      return uploadFile(path, file);
    });
    return Future.wait(futures);
  }

  /// Deletes a file at a specific path.
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }
}
