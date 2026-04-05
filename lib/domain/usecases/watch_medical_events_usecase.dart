import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/repositories/event_repository_interface.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchMedicalEventsUseCase {
  WatchMedicalEventsUseCase(this._repository);
  final EventRepository _repository;

  Stream<List<MedicalEvent>> call(String familyId) {
    return _repository.watchMedicalEvents(familyId);
  }
}
