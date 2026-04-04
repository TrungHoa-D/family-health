import 'package:family_health/domain/entities/health_profile.dart';

abstract class HealthRepository {
  Future<void> saveHealthProfile(String uid, HealthProfile profile);
  Future<HealthProfile?> getHealthProfile(String uid);
}
