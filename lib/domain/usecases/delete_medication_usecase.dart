import 'package:family_health/domain/usecases/use_case.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteMedicationUseCase implements UseCase<void, String> {
  DeleteMedicationUseCase(this._repository);

  final MedicationRepository _repository;

  @override
  Future<void> call({required String params}) {
    return _repository.deleteMedication(params);
  }
}
