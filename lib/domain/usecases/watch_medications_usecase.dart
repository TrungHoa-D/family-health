import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchMedicationsUseCase {
  WatchMedicationsUseCase(this._medicationRepository);
  final MedicationRepository _medicationRepository;

  Stream<List<Medication>> call(String familyId) {
    return _medicationRepository.watchMedications(familyId);
  }
}
