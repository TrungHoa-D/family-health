import 'dart:async';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/medication_log.dart';
import 'package:family_health/domain/usecases/add_medication_log_usecase.dart';
import 'package:family_health/domain/usecases/get_health_profile_usecase.dart';
import 'package:family_health/domain/usecases/get_medication_logs_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_family_schedules_usecase.dart';
import 'package:family_health/domain/usecases/watch_medical_events_usecase.dart';
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
    this._watchMedicalEventsUseCase,
    this._getHealthProfileUseCase,
    this._getUserUseCase,
    this._addMedicationLogUseCase,
    this._getMedicationLogsUseCase,
    this._fcmService,
  );

  final NotificationService _notificationService;
  final WatchFamilySchedulesUseCase _watchFamilySchedulesUseCase;
  final WatchMedicalEventsUseCase _watchMedicalEventsUseCase;
  final GetHealthProfileUseCase _getHealthProfileUseCase;
  final GetUserUseCase _getUserUseCase;
  final AddMedicationLogUseCase _addMedicationLogUseCase;
  final GetMedicationLogsUseCase _getMedicationLogsUseCase;
  final FcmService _fcmService;

  StreamSubscription? _scheduleSubscription;
  StreamSubscription? _eventsSubscription;
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

    _eventsSubscription?.cancel();
    _eventsSubscription =
        _watchMedicalEventsUseCase.call(familyId).listen((events) async {
      await _rescheduleAllEvents(user.uid, familyId, events);
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

  Future<void> _rescheduleAllEvents(
    String currentUserId,
    String familyId,
    List<MedicalEvent> events,
  ) async {
    // Để giữ id notification duy nhất và có thể cancel, _rescheduleAllEvents sẽ KHÔNG gọi cancelAll
    // Thay vào đó, notification service hiện không có cancelAll for specific tags (vì local notification plugin ko support tag/grouping tốt),
    // nhưng ta có thể hủy dựa vào hash của event ID (đang làm trong NotificationService nhưng ta sẽ làm ở đây luôn).
    // Đơn giản nhất: gọi cancelEventReminders bên trong hàm nếu cần, nhưng ta ko loop cancelAllEvent được dễ dàng nêys ko lưu id.
    // Vì vậy ta set ID cố định dựa trên sự kiện và thời gian để nó sẽ đè lên ID cũ.

    final healthProfile =
        await _getHealthProfileUseCase.call(params: currentUserId);
    final anchorTimes = healthProfile?.anchorTimes ?? const AnchorTimes();

    for (final event in events) {
      // Chỉ lập lịch nếu user hiện tại là người tham gia
      if (!event.participantIds.contains(currentUserId)) continue;
      
      // Bỏ qua event đã kết thúc/hoàn thành hoặc đã bị hủy
      if (event.finished || event.status == 'CANCELLED' || event.status == 'COMPLETED') continue;
      
      final baseId = event.id.hashCode.abs() % 1000000000; // Đẩy base id xa ra khỏi medication
      final notificationBaseId = baseId + 100000;

      // Hủy mấy cái reminder cũ cho chắc ăn 
      for (int i = 0; i < 5; i++) {
        await _notificationService.cancelNotification(notificationBaseId + i);
      }

      switch(event.timeMode) {
        case 'all_day':
          // Event cả ngày gửi lúc 6h sáng và 17h
          final dayStart = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
          await _scheduleEventNotification(
            id: notificationBaseId,
            title: '📅 Sự kiện hôm nay: ${event.title}',
            body: 'Sự kiện diễn ra cả ngày hôm nay',
            time: dayStart.add(const Duration(hours: 6)),
            payload: 'event_${event.id}',
          );
          await _scheduleEventNotification(
            id: notificationBaseId + 1,
            title: '📅 Sự kiện diễn ra: ${event.title}',
            body: 'Nhắc nhở sự kiện đang diễn ra hôm nay',
            time: dayStart.add(const Duration(hours: 17)),
            payload: 'event_${event.id}',
          );
          break;
        case 'meal_based':
          // Event bữa ăn: dựa trên anchor time (breakfast, lunch, dinner)
          final anchorStr = _getAnchorTimeStr(event.mealTime ?? 'breakfast', anchorTimes);
          if (anchorStr != null) {
            final parsedTime = _parseTimeString(anchorStr);
            final mealTime = DateTime(event.startTime.year, event.startTime.month, event.startTime.day, parsedTime.hour, parsedTime.minute);
            
            // trước 15p
            await _scheduleEventNotification(
              id: notificationBaseId,
              title: '🍽️ Sắp tới giờ ${event.mealTime == 'lunch' ? 'ăn trưa' : event.mealTime == 'dinner' ? 'ăn tối' : 'ăn sáng'}',
              body: 'Trong vòng 15 phút tới bạn có sự kiện: ${event.title}',
              time: mealTime.subtract(const Duration(minutes: 15)),
              payload: 'event_${event.id}',
            );
            
            // sau 15p
            await _scheduleEventNotification(
              id: notificationBaseId + 1,
              title: '🍽️ Nhắc nhở sau ăn',
              body: 'Sự kiện của bạn: ${event.title}',
              time: mealTime.add(const Duration(minutes: 15)),
              payload: 'event_${event.id}',
            );
          }
          break;
        case 'from_to':
        default:
          // lúc bắt đầu sự kiện
          await _scheduleEventNotification(
            id: notificationBaseId,
            title: '🟢 Đang diễn ra: ${event.title}',
            body: 'Sự kiện đã chính thức bắt đầu',
            time: event.startTime,
            payload: 'event_${event.id}',
          );
          // trước 1h
          await _scheduleEventNotification(
            id: notificationBaseId + 1,
            title: '⏰ Sắp diễn ra: ${event.title}',
            body: 'Còn 1 giờ nữa là đến sự kiện',
            time: event.startTime.subtract(const Duration(hours: 1)),
            payload: 'event_${event.id}',
          );
          // trước 15p
          await _scheduleEventNotification(
            id: notificationBaseId + 2,
            title: '⏰ Sắp diễn ra: ${event.title}',
            body: 'Sự kiện sẽ bắt đầu trong 15 phút tới',
            time: event.startTime.subtract(const Duration(minutes: 15)),
            payload: 'event_${event.id}',
          );
          // trước kết thúc 15p
          await _scheduleEventNotification(
            id: notificationBaseId + 3,
            title: '⏳ Sắp kết thúc: ${event.title}',
            body: 'Còn 15 phút nữa là kết thúc sự kiện',
            time: event.endTime.subtract(const Duration(minutes: 15)),
            payload: 'event_${event.id}',
          );
          // kết thúc
          await _scheduleEventNotification(
            id: notificationBaseId + 4,
            title: '✅ Kết thúc: ${event.title}',
            body: 'Sự kiện đã kết thúc, bạn có thể đánh dấu hoàn thành',
            time: event.endTime,
            payload: 'event_${event.id}',
          );
          break;
      }
    }
  }

  Future<void> _scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String payload,
  }) async {
    if (time.isBefore(DateTime.now())) return;
    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: time,
      payload: payload,
    );
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
    _eventsSubscription?.cancel();
    _notificationResponseSubscription?.cancel();
    _anchorTimesCache.clear();
    _fcmService.stop();
  }
}
