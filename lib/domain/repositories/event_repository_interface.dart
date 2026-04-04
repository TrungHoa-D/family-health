import 'package:family_health/domain/entities/medical_event.dart';

abstract class EventRepository {
  Future<void> saveMedicalEvent(MedicalEvent event);
  Stream<List<MedicalEvent>> watchMedicalEvents(String familyId);
}
