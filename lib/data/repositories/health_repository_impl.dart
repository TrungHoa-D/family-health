import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_health/data/models/health_profile_model.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/repositories/health_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  final FirebaseFirestore _firestore;

  HealthRepositoryImpl(this._firestore);

  @override
  Future<void> saveHealthProfile(String uid, HealthProfile profile) async {
    final data = HealthProfileModel.toJson(profile);
    await _firestore
        .collection('health_profiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<HealthProfile?> getHealthProfile(String uid) async {
    final doc = await _firestore.collection('health_profiles').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return HealthProfileModel.fromJson(doc.data()!);
    }
    return null;
  }
}
