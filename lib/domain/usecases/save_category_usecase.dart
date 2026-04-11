import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveCategoryUseCase {
  SaveCategoryUseCase(this._medicationRepository);
  final MedicationRepository _medicationRepository;

  Future<void> call({required MedicationCategory params}) {
    return _medicationRepository.saveCategory(params);
  }
}
