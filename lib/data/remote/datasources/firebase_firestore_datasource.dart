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

  Stream<Map<String, dynamic>?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) => doc.data());
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

  Future<void> deleteFamilyGroup(String id) async {
    await _firestore.collection('family_groups').doc(id).delete();
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

  Stream<List<Map<String, dynamic>>> watchFamilySchedules(String familyId) {
    return _firestore
        .collection('patient_schedules')
        .where('family_id', isEqualTo: familyId)
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
        // .orderBy('timestamp', descending: true) // Requires composite index on Firestore
        // .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Medication Log Methods ---
  Future<void> saveMedicationLog(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('medication_logs') : id;
    final finalData = {...data, 'log_id': docId};
    await _firestore.collection('medication_logs').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Future<List<Map<String, dynamic>>> getMedicationLogs(
    String familyId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection('medication_logs')
        .where('family_id', isEqualTo: familyId)
        .where('scheduled_time', isGreaterThanOrEqualTo: startOfDay)
        .where('scheduled_time', isLessThan: endOfDay)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  // --- AI Chat History Methods ---
  Future<void> saveAIChatMessage(String id, Map<String, dynamic> data) async {
    final docId = id.isEmpty ? generateId('ai_chat_history') : id;
    final finalData = {...data, 'id': docId};
    await _firestore.collection('ai_chat_history').doc(docId).set(
          finalData,
          SetOptions(merge: true),
        );
  }

  Stream<List<Map<String, dynamic>>> watchAIChatMessages(String userId) {
    return _firestore
        .collection('ai_chat_history')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      // Sắp xếp thủ công theo timestamp để tránh lỗi Index
      docs.sort((a, b) {
        final tsA = a['timestamp'];
        final tsB = b['timestamp'];
        if (tsA is Timestamp && tsB is Timestamp) {
          return tsA.compareTo(tsB);
        }
        return 0;
      });

      return docs;
    });
  }
}
