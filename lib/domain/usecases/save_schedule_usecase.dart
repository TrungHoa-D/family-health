import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SaveScheduleUseCase extends UseCase<void, PatientSchedule> {
  SaveScheduleUseCase(this._repository);
  final MedicationRepository _repository;

  @override
  Future<void> call({required PatientSchedule params}) {
    return _repository.saveSchedule(params);
  }
}
