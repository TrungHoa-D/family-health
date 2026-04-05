import 'package:family_health/domain/entities/home_stats.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTodayStatsUseCase implements UseCase<HomeStats, String> {
  GetTodayStatsUseCase(this._medicationRepository);
  final MedicationRepository _medicationRepository;

  @override
  Future<HomeStats> call({required String params}) async {
    final now = DateTime.now();
    
    // 1. Get all family schedules (Wait, repository has watchFamilySchedules, or I can use existing getFamilySchedules if I had one)
    // For now, I'll use watchFamilySchedules and take first list.
    final schedules = await _medicationRepository.watchFamilySchedules(params).first;
    
    // 2. Get today's logs
    final logs = await _medicationRepository.getMedicationLogs(params, now);
    
    final totalDoses = schedules.length;
    final takenCount = logs.where((l) => l.status == 'TAKEN').length;
    final missedCount = logs.where((l) => l.status == 'MISSED').length;
    
    double percentage = 0.0;
    if (totalDoses > 0) {
      percentage = (takenCount / totalDoses) * 100;
    }

    return HomeStats(
      totalDoses: totalDoses,
      takenDoses: takenCount,
      missedDoses: missedCount,
      completionPercentage: percentage,
    );
  }
}
