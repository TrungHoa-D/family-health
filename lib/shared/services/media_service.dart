import 'dart:io';
import 'package:family_health/data/remote/datasources/firebase_storage_datasource.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MediaService {
  MediaService(this._storageDataSource) : _picker = ImagePicker();

  final FirebaseStorageDataSource _storageDataSource;
  final ImagePicker _picker;

  /// Picks an image from the specified source.
  Future<File?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70, // Optimize image size
      maxWidth: 1024,
    );

    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  /// Uploads a file to Firebase Storage and returns the public URL.
  Future<String> uploadImage(String path, File file) async {
    return _storageDataSource.uploadFile(path, file);
  }

  /// Combined method: Picks from gallery/camera and uploads.
  Future<String?> pickAndUploadImage({
    required String storagePath,
    required ImageSource source,
  }) async {
    final File? file = await pickImage(source);
    if (file == null) return null;
    return uploadImage(storagePath, file);
  }
}
