import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MedicationRepository)
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(this._dataSource);
  final FirebaseFirestoreDataSource _dataSource;

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
}
