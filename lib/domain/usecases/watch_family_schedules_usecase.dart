import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchFamilySchedulesUseCase extends UseCaseStream<List<PatientSchedule>, String> {
  WatchFamilySchedulesUseCase(this._repository);
  final MedicationRepository _repository;

  @override
  Stream<List<PatientSchedule>> call(String params) {
    return _repository.watchFamilySchedules(params);
  }
}
