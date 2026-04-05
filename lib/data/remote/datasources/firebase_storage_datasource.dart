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

  /// Deletes a file at a specific path.
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }
}
