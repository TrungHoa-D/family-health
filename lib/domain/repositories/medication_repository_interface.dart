import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';

abstract class MedicationRepository {
  Future<void> saveMedication(Medication medication);
  Stream<List<Medication>> watchMedications(String familyId);
  Future<void> saveSchedule(PatientSchedule schedule);
  Stream<List<PatientSchedule>> watchSchedules(String targetUserId);
}
