import 'dart:io';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';

abstract class MedicationRepository {
  Future<void> saveMedication(Medication medication);
  Stream<List<Medication>> watchMedications(String familyId);
  Future<void> saveSchedule(PatientSchedule schedule);
  Stream<List<PatientSchedule>> watchSchedules(String targetUserId);
  Stream<List<PatientSchedule>> watchFamilySchedules(String familyId);
  Future<String> uploadMedicationImage(String medId, File image);

  // Medication Logs
  Future<void> saveMedicationLog(MedicationLog log);
  Future<List<MedicationLog>> getMedicationLogs(String familyId, DateTime date);
}
