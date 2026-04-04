import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/repositories/event_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._dataSource);
  final FirebaseFirestoreDataSource _dataSource;

  @override
  Future<void> saveMedicalEvent(MedicalEvent event) {
    return _dataSource.saveMedicalEvent(event.id, event.toJson());
  }

  @override
  Stream<List<MedicalEvent>> watchMedicalEvents(String familyId) {
    return _dataSource.watchMedicalEvents(familyId).map(
          (list) => list.map((json) => MedicalEvent.fromJson(json)).toList(),
        );
  }
}
