import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchCategoriesUseCase {
  WatchCategoriesUseCase(this._medicationRepository);
  final MedicationRepository _medicationRepository;

  Stream<List<MedicationCategory>> call() {
    return _medicationRepository.watchCategories();
  }
}

