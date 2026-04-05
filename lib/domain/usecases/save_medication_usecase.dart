import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveMedicationUseCase implements UseCase<void, Medication> {
  SaveMedicationUseCase(this._medicationRepository);
  final MedicationRepository _medicationRepository;

  @override
  Future<void> call({required Medication params}) async {
    return _medicationRepository.saveMedication(params);
  }
}
