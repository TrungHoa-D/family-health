import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddMedicationLogUseCase extends UseCase<void, MedicationLog> {
  AddMedicationLogUseCase(this._repository);
  final MedicationRepository _repository;

  @override
  Future<void> call({required MedicationLog params}) {
    return _repository.saveMedicationLog(params);
  }
}
