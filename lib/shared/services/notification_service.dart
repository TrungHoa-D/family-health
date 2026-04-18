import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';

@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Will request later explicitly
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'Family Health',
      appUserModelId: 'com.trunghoa.family_health',
      guid: 'E8E22534-C7CA-4AEA-A3B6-2C7C3DCD9B0F',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }

    // Create notification channel for Android
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'family_health_reminders',
            'Nhắc nhở uống thuốc',
            description: 'Thông báo nhắc nhở uống thuốc cho gia đình',
            importance: Importance.max,
          ));
    }
  }

  final _responsesController =
      StreamController<NotificationResponse>.broadcast();
  Stream<NotificationResponse> get onResponse => _responsesController.stream;

  void _onNotificationResponse(NotificationResponse details) {
    _responsesController.add(details);
    // Logic xử lý khi click vào thông báo hoặc nút action
    debugPrint('Notification clicked: ${details.payload}');
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'family_health_reminders',
      'Nhắc nhở uống thuốc',
      channelDescription: 'Thông báo nhắc nhở uống thuốc cho gia đình',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'family_health_reminders',
          'Nhắc nhở uống thuốc',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  // --- Helpers for Family Health ---

  static const Map<String, ({int hour, int minute})> anchorTimes = {
    'Sau ăn sáng': (hour: 8, minute: 30),
    'Sau ăn trưa': (hour: 12, minute: 30),
    'Sau ăn tối': (hour: 19, minute: 30),
    'Trước đi ngủ': (hour: 21, minute: 30),
  };

  DateTime _getDateTimeFromAnchor(String anchor, int offsetMinutes, int dayOffset) {
    final now = DateTime.now();
    final targetDay = now.add(Duration(days: dayOffset));
    
    final time = anchorTimes[anchor] ?? (hour: 8, minute: 0);
    
    final baseTime = DateTime(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      time.hour,
      time.minute,
    ).add(Duration(minutes: offsetMinutes));
    
    return baseTime;
  }

  Future<void> scheduleMedicationReminders(PatientSchedule schedule) async {
    final anchor = schedule.timing['anchor_event'] as String? ?? 'Sau ăn sáng';
    final offset = (schedule.timing['offset'] as num?)?.toInt() ?? 30;

    // Schedule for next 7 days
    for (int i = 0; i < 7; i++) {
        final scheduledTime = _getDateTimeFromAnchor(anchor, offset, i);
        if (scheduledTime.isBefore(DateTime.now())) continue;

        // Create a unique ID for this instance: base hash + day offset
        final id = schedule.id.hashCode + i;
        
        await scheduleNotification(
          id: id,
          title: '💊 Nhắc nhở uống thuốc',
          body: '${schedule.targetUserId == "myself" ? "Bạn" : "Bố/Mẹ"} có liều thuốc ${schedule.medName} (${schedule.dosage})',
          scheduledDate: scheduledTime,
          payload: 'med_${schedule.id}',
        );
    }
  }

  Future<void> cancelMedicationReminders(String scheduleId) async {
    // Cancel all IDs in the range [hashCode, hashCode + 7]
    final baseId = scheduleId.hashCode;
    for (int i = 0; i < 7; i++) {
      await cancelNotification(baseId + i);
    }
  }
}
