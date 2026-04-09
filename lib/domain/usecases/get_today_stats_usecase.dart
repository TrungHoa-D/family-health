import 'package:family_health/domain/entities/home_stats.dart';
import 'package:family_health/domain/entities/medication_alert.dart';
import 'package:family_health/domain/repositories/medication_repository_interface.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTodayStatsUseCase implements UseCase<HomeStats, String> {
  GetTodayStatsUseCase(this._medicationRepository, this._userRepository);
  final MedicationRepository _medicationRepository;
  final UserRepository _userRepository;

  @override
  Future<HomeStats> call({required String params}) async {
    final now = DateTime.now();
    final familyId = params;

    // 1. Get all family schedules
    final schedules =
        await _medicationRepository.watchFamilySchedules(familyId).first;

    // 2. Get today's logs
    final logs = await _medicationRepository.getMedicationLogs(familyId, now);

    // 3. Get family members for names
    final memberIds = schedules.map((s) => s.targetUserId).toSet().toList();
    final members = await _userRepository.getUsers(memberIds);
    final memberNames = {for (var m in members) m.uid: m.displayName ?? 'Thành viên'};

    final totalDoses = schedules.length;
    final takenCount = logs.where((l) => l.status == 'TAKEN').length;
    final missedCount = logs.where((l) => l.status == 'MISSED').length;

    // 4. Calculate Alerts (Delayed doses)
    final List<MedicationAlert> alerts = [];
    for (final schedule in schedules) {
      final hasTaken = logs.any((l) =>
          l.scheduleId == schedule.id &&
          l.status == 'TAKEN');
      
      if (!hasTaken) {
         // Check if delayed
         // For demo, we assume scheduledTime is based on anchor_event
         // For now, let's just add one dummy alert if there's any pending to show UI works
         if (schedule.medName.contains('Huyết áp')) {
           alerts.add(MedicationAlert(
             scheduleId: schedule.id,
             userName: memberNames[schedule.targetUserId] ?? 'Thành viên',
             medName: schedule.medName,
             dosage: schedule.dosage,
             scheduledTime: now.subtract(const Duration(minutes: 23)),
             delayMinutes: 23,
           ));
         }
      }
    }

    double percentage = 0.0;
    if (totalDoses > 0) {
      percentage = (takenCount / totalDoses) * 100;
    }

    return HomeStats(
      totalDoses: totalDoses,
      takenDoses: takenCount,
      missedDoses: missedCount,
      completionPercentage: percentage,
      alerts: alerts,
    );
  }
}
