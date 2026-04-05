import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseFirestoreDataSource {
  FirebaseFirestoreDataSource(this._firestore);
  final FirebaseFirestore _firestore;

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

  // --- Family Group Methods ---
  Future<void> createFamilyGroup(String id, Map<String, dynamic> data) async {
    await _firestore.collection('family_groups').doc(id).set(data);
  }

  Future<void> updateFamilyGroup(String id, Map<String, dynamic> data) async {
    await _firestore.collection('family_groups').doc(id).update(data);
  }

  Future<Map<String, dynamic>?> getFamilyByInviteCode(String code) async {
    final query = await _firestore
        .collection('family_groups')
        .where('invitationCode', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      return null;
    }
    return query.docs.first.data();
  }

  Future<Map<String, dynamic>?> getFamilyGroup(String id) async {
    final doc = await _firestore.collection('family_groups').doc(id).get();
    return doc.data();
  }

  Future<void> saveHealthProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_profiles')
        .doc('current') // Mỗi user 1 profile hiện tại
        .set(data);
  }

  Future<Map<String, dynamic>?> getHealthProfile(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_profiles')
        .doc('current')
        .get();
    return doc.data();
  }

  // --- Helper Methods ---
  String generateId(String collectionPath) {
    return _firestore.collection(collectionPath).doc().id;
  }

  // --- Medication Methods ---
  Future<void> saveMedication(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('medications') : id;
    final finalData = {...data, 'id': docId};
    await _firestore.collection('medications').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Stream<List<Map<String, dynamic>>> watchMedications(String familyId) {
    return _firestore
        .collection('medications')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Patient Schedule Methods ---
  Future<void> saveSchedule(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('patient_schedules') : id;
    final finalData = {...data, 'id': docId};
    await _firestore.collection('patient_schedules').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Stream<List<Map<String, dynamic>>> watchSchedules(String targetUserId) {
    return _firestore
        .collection('patient_schedules')
        .where('target_user_id', isEqualTo: targetUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Medical Event Methods ---
  Future<void> saveMedicalEvent(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('medical_events') : id;
    final finalData = {...data, 'id': docId};
    await _firestore.collection('medical_events').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Stream<List<Map<String, dynamic>>> watchMedicalEvents(String familyId) {
    return _firestore
        .collection('medical_events')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Chat Methods ---
  Future<void> sendMessage(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('chats') : id;
    final finalData = {...data, 'id': docId};
    await _firestore.collection('chats').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Stream<List<Map<String, dynamic>>> watchChatMessages(String familyId) {
    return _firestore
        .collection('chats')
        .where('family_id', isEqualTo: familyId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
