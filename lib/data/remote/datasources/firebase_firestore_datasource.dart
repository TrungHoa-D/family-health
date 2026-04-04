import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseFirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreDataSource(this._firestore);

  Future<void> syncUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(
      userData,
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
