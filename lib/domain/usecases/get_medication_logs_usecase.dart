import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class GetMedicationLogsParams {
  GetMedicationLogsParams({required this.familyId, required this.date});
  final String familyId;
  final DateTime date;
}

@injectable
class GetMedicationLogsUseCase extends UseCase<List<MedicationLog>, GetMedicationLogsParams> {
  GetMedicationLogsUseCase(this._repository);
  final MedicationRepository _repository;

  @override
  Future<List<MedicationLog>> call({required GetMedicationLogsParams params}) {
    return _repository.getMedicationLogs(params.familyId, params.date);
  }
}
