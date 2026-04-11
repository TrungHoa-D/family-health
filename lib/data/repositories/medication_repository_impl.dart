import 'dart:io';
import 'package:family_health/data/models/medication_log_model.dart';
import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/data/remote/datasources/firebase_storage_datasource.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MedicationRepository)
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(this._dataSource, this._storageDataSource);
  final FirebaseFirestoreDataSource _dataSource;
  final FirebaseStorageDataSource _storageDataSource;

  @override
  Future<void> saveMedication(Medication medication) {
    return _dataSource.saveMedication(medication.id, medication.toJson());
  }

  @override
  Stream<List<Medication>> watchMedications(String familyId) {
    return _dataSource.watchMedications(familyId).map(
          (list) => list.map((json) => Medication.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> saveSchedule(PatientSchedule schedule) {
    return _dataSource.saveSchedule(schedule.id, schedule.toJson());
  }

  @override
  Stream<List<PatientSchedule>> watchSchedules(String targetUserId) {
    return _dataSource.watchSchedules(targetUserId).map(
          (list) => list.map((json) => PatientSchedule.fromJson(json)).toList(),
        );
  }

  @override
  Stream<List<PatientSchedule>> watchFamilySchedules(String familyId) {
    return _dataSource.watchFamilySchedules(familyId).map(
          (list) => list.map((json) => PatientSchedule.fromJson(json)).toList(),
        );
  }

  @override
  Future<String> uploadMedicationImage(String medId, File image) async {
    final path = 'medications/$medId.jpg';
    return await _storageDataSource.uploadFile(path, image);
  }

  @override
  Future<void> deleteMedication(String medId) async {
    await Future.wait([
      _dataSource.deleteMedication(medId),
      _dataSource.deleteSchedulesByMedId(medId),
    ]);
  }

  @override
  Stream<List<MedicationCategory>> watchCategories() {
    return _dataSource.watchCategories().map(
          (list) =>
              list.map((json) => MedicationCategory.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> saveCategory(MedicationCategory category) {
    return _dataSource.saveCategory(category.id, category.toJson());
  }

  @override
  Future<void> saveMedicationLog(MedicationLog log) {
    return _dataSource.saveMedicationLog(
      log.logId,
      MedicationLogModel.fromEntity(log).toJson(),
    );
  }

  @override
  Future<List<MedicationLog>> getMedicationLogs(String familyId, DateTime date) async {
    final list = await _dataSource.getMedicationLogs(familyId, date);
    return list.map((json) => MedicationLogModel.fromJson(json).toEntity()).toList();
  }
}

