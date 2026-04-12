import 'package:family_health/domain/entities/home_stats.dart';
import 'package:family_health/domain/entities/medication_alert.dart';
import 'package:family_health/domain/entities/member_stats.dart';
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

    // 1. Lấy tất cả schedules của gia đình
    final schedules =
        await _medicationRepository.watchFamilySchedules(familyId).first;

    // 2. Lấy logs hôm nay
    final logs = await _medicationRepository.getMedicationLogs(familyId, now);

    // 3. Lấy thông tin thành viên
    final memberIds = schedules.map((s) => s.targetUserId).toSet().toList();
    final members = await _userRepository.getUsers(memberIds);
    final memberMap = {for (var m in members) m.uid: m};

    // 4. Tổng hợp stats toàn gia đình
    final totalDoses = schedules.length;
    final takenCount = logs.where((l) => l.status == 'TAKEN').length;
    final missedCount = logs.where((l) => l.status == 'MISSED').length;

    // 5. Tính tiến độ từng thành viên
    final List<MemberStats> memberStats = [];
    for (final userId in memberIds) {
      final member = memberMap[userId];
      if (member == null) continue;

      final memberSchedules =
          schedules.where((s) => s.targetUserId == userId).toList();
      final memberTaken = logs
          .where((l) =>
              l.status == 'TAKEN' &&
              memberSchedules.any((s) => s.id == l.scheduleId))
          .length;

      memberStats.add(MemberStats(
        userId: userId,
        displayName: member.displayName ?? 'Thành viên',
        avatarUrl: member.avatarUrl,
        takenDoses: memberTaken,
        totalDoses: memberSchedules.length,
      ));
    }

    // 6. Tính alerts: PENDING logs đã trễ >= 15 phút
    final List<MedicationAlert> alerts = [];
    final pendingLogs = logs.where((l) => l.status == 'PENDING').toList();
    for (final log in pendingLogs) {
      final delayMinutes =
          now.difference(log.scheduledTime).inMinutes;
      if (delayMinutes < 15) continue;

      final schedule = schedules.firstWhere(
        (s) => s.id == log.scheduleId,
        orElse: () => schedules.first, // fallback an toàn
      );

      // Chỉ thêm alert nếu tìm thấy đúng schedule
      if (schedule.id != log.scheduleId) continue;

      final member = memberMap[schedule.targetUserId];
      alerts.add(MedicationAlert(
        scheduleId: log.scheduleId,
        userName: member?.displayName ?? 'Thành viên',
        medName: schedule.medName,
        dosage: schedule.dosage,
        scheduledTime: log.scheduledTime,
        delayMinutes: delayMinutes,
      ));
    }

    // 7. Tính phần trăm hoàn thành
    final double percentage =
        totalDoses > 0 ? (takenCount / totalDoses) * 100 : 0.0;

    return HomeStats(
      totalDoses: totalDoses,
      takenDoses: takenCount,
      missedDoses: missedCount,
      completionPercentage: percentage,
      alerts: alerts,
      memberStats: memberStats,
    );
  }
}
