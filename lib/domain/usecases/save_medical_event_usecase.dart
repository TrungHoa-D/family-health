import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/repositories/event_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveMedicalEventUseCase extends UseCase<void, MedicalEvent> {
  SaveMedicalEventUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<void> call({required MedicalEvent params}) {
    return _repository.saveMedicalEvent(params);
  }
}
