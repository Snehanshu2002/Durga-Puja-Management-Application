import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/datasources/notification_remote_datasource.dart';

class FcmService {
  final FirebaseMessaging _fcm;
  final NotificationRemoteDataSource _remoteDataSource;

  FcmService(this._fcm, this._remoteDataSource);

  Future<void> initialize(String currentUserId) async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _fcm.getToken();
        final platformName = kIsWeb ? 'web' : defaultTargetPlatform.name;
        if (token != null) {
          final deviceId = '${currentUserId}_$platformName';
          await _remoteDataSource.saveUserDeviceToken(
            userId: currentUserId,
            deviceId: deviceId,
            token: token,
            platform: platformName,
          );
        }

        _fcm.onTokenRefresh.listen((newToken) async {
          final deviceId = '${currentUserId}_$platformName';
          await _remoteDataSource.saveUserDeviceToken(
            userId: currentUserId,
            deviceId: deviceId,
            token: newToken,
            platform: platformName,
          );
        });
      }
    } catch (_) {
      // Gracefully handle FCM Web / Permission restrictions without crashing
    }
  }

  Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String body,
    required String type,
    required String entityType,
    required String entityId,
    required String eventId,
  }) async {
    final notification = AppNotificationModel(
      id: '',
      userId: targetUserId,
      title: title,
      body: body,
      type: type,
      entityType: entityType,
      entityId: entityId,
      eventId: eventId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _remoteDataSource.sendNotification(notification);
  }
}
