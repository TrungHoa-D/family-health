import 'dart:io';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';

abstract class MedicationRepository {
  Future<void> saveMedication(Medication medication);
  Stream<List<Medication>> watchMedications(String familyId);
  Future<void> saveSchedule(PatientSchedule schedule);
  Stream<List<PatientSchedule>> watchSchedules(String targetUserId);
  Stream<List<PatientSchedule>> watchFamilySchedules(String familyId);
  Future<String> uploadMedicationImage(String medId, File image);
  Future<void> deleteMedication(String medId);

  // Medication Categories
  Stream<List<MedicationCategory>> watchCategories();
  Future<void> saveCategory(MedicationCategory category);

  // Medication Logs
  Future<void> saveMedicationLog(MedicationLog log);
  Future<List<MedicationLog>> getMedicationLogs(String familyId, DateTime date);
}
