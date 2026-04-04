import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._dataSource);
  final FirebaseFirestoreDataSource _dataSource;

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
}
