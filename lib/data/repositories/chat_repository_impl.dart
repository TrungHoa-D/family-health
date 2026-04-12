import 'dart:io';

import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/data/remote/datasources/firebase_storage_datasource.dart';
import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._dataSource, this._storageDataSource);
  final FirebaseFirestoreDataSource _dataSource;
  final FirebaseStorageDataSource _storageDataSource;

  @override
  Future<void> sendMessage(ChatMessage message) {
    return _dataSource.sendMessage(message.id, message.toJson());
  }

  @override
  Stream<List<ChatMessage>> watchChatMessages(String familyId) {
    return _dataSource.watchChatMessages(familyId).map(
          (list) => list.map((json) => ChatMessage.fromJson(json)).toList(),
        );
  }

  @override
  Future<List<String>> uploadChatImages(String familyId, List<File> files) {
    return _storageDataSource.uploadFiles('chat_images/$familyId', files);
  }

  @override
  Future<void> deleteMessage(String id) {
    return _dataSource.deleteChatMessage(id);
  }

  @override
  Future<void> updateMessage(String id, String content) {
    return _dataSource.updateChatMessage(id, content);
  }
}
