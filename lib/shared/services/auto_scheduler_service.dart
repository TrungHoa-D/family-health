import 'dart:async';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/usecases/add_medication_log_usecase.dart';
import 'package:family_health/domain/usecases/get_health_profile_usecase.dart';
import 'package:family_health/domain/usecases/get_medication_logs_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_family_schedules_usecase.dart';
import 'package:family_health/shared/services/fcm_service.dart';
import 'package:family_health/shared/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@singleton
class AutoSchedulerService {
  AutoSchedulerService(
    this._notificationService,
    this._watchFamilySchedulesUseCase,
    this._getHealthProfileUseCase,
    this._getUserUseCase,
    this._addMedicationLogUseCase,
    this._getMedicationLogsUseCase,
    this._fcmService,
  );

  final NotificationService _notificationService;
  final WatchFamilySchedulesUseCase _watchFamilySchedulesUseCase;
  final GetHealthProfileUseCase _getHealthProfileUseCase;
  final GetUserUseCase _getUserUseCase;
  final AddMedicationLogUseCase _addMedicationLogUseCase;
  final GetMedicationLogsUseCase _getMedicationLogsUseCase;
  final FcmService _fcmService;

  StreamSubscription? _scheduleSubscription;
  StreamSubscription? _notificationResponseSubscription;

  // Cache anchor_times theo userId để tránh query lặp
  final Map<String, AnchorTimes> _anchorTimesCache = {};

  void start() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEntity = await _getUserUseCase.call(params: user.uid);
    final familyId = userEntity?.familyId;
    if (familyId == null) return;

    // Khởi tạo FCM Service để nhận push messages
    await _fcmService.init(user.uid);

    // Lắng nghe phản hồi từ thông báo
    _notificationResponseSubscription?.cancel();
    _notificationResponseSubscription =
        _notificationService.onResponse.listen((response) {
      _handleNotificationResponse(familyId, response);
    });

    _scheduleSubscription?.cancel();
    _scheduleSubscription =
        _watchFamilySchedulesUseCase.call(familyId).listen((schedules) async {
      _anchorTimesCache.clear(); // Reset cache khi schedules thay đổi
      await _rescheduleAll(user.uid, familyId, schedules);
      await _createTodayPendingLogs(familyId, schedules);
    });
  }

  // ─── Tạo PENDING logs cho hôm nay ────────────────────────────────────────

  Future<void> _createTodayPendingLogs(
    String familyId,
    List<PatientSchedule> schedules,
  ) async {
    if (schedules.isEmpty) return;

    final today = DateTime.now();
    // Query tất cả logs hôm nay của family
    final existingLogs = await _getMedicationLogsUseCase.call(
      params: GetMedicationLogsParams(familyId: familyId, date: today),
    );
    final existingScheduleIds = existingLogs.map((l) => l.scheduleId).toSet();

    for (final schedule in schedules) {
      // Bỏ qua nếu đã có log hôm nay (bất kể status)
      if (existingScheduleIds.contains(schedule.id)) continue;

      final scheduledTime = await _calculateScheduledTimeForMember(
        schedule.timing,
        schedule.targetUserId,
      );
      if (scheduledTime == null) continue;

      final log = MedicationLog(
        logId: const Uuid().v4(),
        familyId: familyId,
        scheduleId: schedule.id,
        scheduledTime: scheduledTime,
        status: 'PENDING',
      );

      try {
        await _addMedicationLogUseCase.call(params: log);
        debugPrint('[AutoScheduler] Created PENDING log for schedule '
            '${schedule.id} at ${scheduledTime.toIso8601String()}');
      } catch (e) {
        debugPrint('[AutoScheduler] Error creating PENDING log: $e');
      }
    }
  }

  /// Tính scheduledTime dựa trên anchor_times của member (có cache)
  Future<DateTime?> _calculateScheduledTimeForMember(
    Map<String, dynamic> timing,
    String targetUserId,
  ) async {
    // Lấy anchor_times từ cache hoặc Firestore
    if (!_anchorTimesCache.containsKey(targetUserId)) {
      final profile = await _getHealthProfileUseCase.call(params: targetUserId);
      _anchorTimesCache[targetUserId] =
          profile?.anchorTimes ?? const AnchorTimes();
    }
    final anchorTimes = _anchorTimesCache[targetUserId]!;

    final anchorEvent = timing['anchor_event'] as String?;
    final offset = (timing['offset'] as num?)?.toInt() ?? 0;

    final baseTimeStr = _getAnchorTimeStr(anchorEvent, anchorTimes);
    if (baseTimeStr == null) return null;

    final baseTime = _parseTimeString(baseTimeStr);
    return baseTime.add(Duration(minutes: offset));
  }

  // ─── Notification response ────────────────────────────────────────────────

  Future<void> _handleNotificationResponse(
      String familyId, dynamic response) async {
    final payload = response.payload;
    if (payload == null) return;

    // Payload format: schedule_id|scheduled_time
    final parts = payload.split('|');
    if (parts.length < 2) return;

    final scheduleId = parts[0];
    final scheduledTime = DateTime.parse(parts[1]);

    final log = MedicationLog(
      logId: const Uuid().v4(),
      familyId: familyId,
      scheduleId: scheduleId,
      scheduledTime: scheduledTime,
      status: 'TAKEN',
      takenTime: DateTime.now(),
    );

    try {
      await _addMedicationLogUseCase.call(params: log);
      debugPrint('[AutoScheduler] Logged TAKEN from notification.');
    } catch (e) {
      debugPrint('[AutoScheduler] Error logging TAKEN from notification: $e');
    }
  }

  // ─── Local notification scheduling ───────────────────────────────────────

  Future<void> _rescheduleAll(
    String currentUserId,
    String familyId,
    List<PatientSchedule> schedules,
  ) async {
    await _notificationService.cancelAll();

    final healthProfile =
        await _getHealthProfileUseCase.call(params: currentUserId);
    final anchorTimes = healthProfile?.anchorTimes ?? const AnchorTimes();

    // Chỉ lên lịch local notification cho schedule của user hiện tại
    final mySchedules =
        schedules.where((s) => s.targetUserId == currentUserId).toList();

    for (var i = 0; i < mySchedules.length; i++) {
      final schedule = mySchedules[i];
      final baseTimeStr = _getAnchorTimeStr(
          schedule.timing['anchor_event'] as String?, anchorTimes);
      if (baseTimeStr == null) continue;

      final baseTime = _parseTimeString(baseTimeStr);
      final offset = (schedule.timing['offset'] as num?)?.toInt() ?? 0;
      final finalTime = baseTime.add(Duration(minutes: offset));

      for (int day = 0; day < 7; day++) {
        final now = DateTime.now();
        final scheduledDate = DateTime(
          now.year,
          now.month,
          now.day + day,
          finalTime.hour,
          finalTime.minute,
        );

        if (scheduledDate.isAfter(now)) {
          final notificationId =
              (schedule.id.hashCode + day).abs() % 2147483647;

          await _notificationService.scheduleNotification(
            id: notificationId,
            title: 'Nhắc nhở uống thuốc',
            body:
                'Đã đến lúc uống ${schedule.medName} (${schedule.dosage})',
            scheduledDate: scheduledDate,
            payload:
                '${schedule.id}|${scheduledDate.toIso8601String()}',
          );
        }
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String? _getAnchorTimeStr(String? event, AnchorTimes anchors) {
    if (event == null) return null;
    switch (event.toLowerCase()) {
      case 'breakfast':
        return anchors.breakfast;
      case 'lunch':
        return anchors.lunch;
      case 'dinner':
        return anchors.dinner;
      case 'sleep':
        return anchors.sleep;
      default:
        return '08:00';
    }
  }

  DateTime _parseTimeString(String timeStr) {
    if (!timeStr.contains(':')) timeStr = '08:00';
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void stop() {
    _scheduleSubscription?.cancel();
    _notificationResponseSubscription?.cancel();
    _anchorTimesCache.clear();
    _fcmService.stop();
  }
}
