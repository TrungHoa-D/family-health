import 'dart:async';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/shared/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class FcmService {
  FcmService(this._userRepository, this._notificationService);

  final UserRepository _userRepository;
  final NotificationService _notificationService;

  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageOpenedSubscription;

  Future<void> init(String uid) async {
    final messaging = FirebaseMessaging.instance;

    // 1. Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // 2. Lấy token mới nhất và cập nhật
      final token = await messaging.getToken();
      if (token != null) {
        await _userRepository.updateFcmToken(uid, token);
      }

      // 3. Lắng nghe token refresh
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) {
        _userRepository.updateFcmToken(uid, newToken);
      });

      // 4. Lắng nghe khi app đang mở (Foreground)
      _messageSubscription?.cancel();
      _messageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 5. Lắng nghe khi bấm vào thông báo để mở app
      _messageOpenedSubscription?.cancel();
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    } else {
      debugPrint('[FcmService] User declined or has not accepted permission');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FcmService] Received foreground message: ${message.messageId}');
    
    // Hiển thị thông báo khi đang mở app
    if (message.notification != null) {
      _notificationService.showNotification(
        id: message.messageId.hashCode,
        title: message.notification!.title ?? 'Thông báo',
        body: message.notification!.body ?? '',
      );
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('[FcmService] Opened notification click: ${message.messageId}');
    // TODO: Có thể chuyển hướng trang dựa vào message.data
  }

  void stop() {
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
  }
}
