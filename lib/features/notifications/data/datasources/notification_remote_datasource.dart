import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification_model.dart';
import '../../../../core/error/app_exception.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendNotification(AppNotificationModel notification);
  Future<List<AppNotificationModel>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> saveUserDeviceToken({
    required String userId,
    required String deviceId,
    required String token,
    required String platform,
  });
  Future<void> deactivateDeviceToken({
    required String userId,
    required String deviceId,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl(this._firestore);

  CollectionReference get _notificationsRef => _firestore.collection('notifications');
  CollectionReference get _userDevicesRef => _firestore.collection('user_devices');

  @override
  Future<void> sendNotification(AppNotificationModel notification) async {
    try {
      final docRef = notification.id.isNotEmpty
          ? _notificationsRef.doc(notification.id)
          : _notificationsRef.doc();

      final newNotif = AppNotificationModel(
        id: docRef.id,
        userId: notification.userId,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        entityType: notification.entityType,
        entityId: notification.entityId,
        eventId: notification.eventId,
        isRead: notification.isRead,
        createdAt: notification.createdAt,
      );
      await docRef.set(newNotif.toFirestore());
    } catch (e) {
      throw AppException('Failed to send notification: ${e.toString()}');
    }
  }

  @override
  Future<List<AppNotificationModel>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .limit(50)
          .get();
      final docs = snapshot.docs
          .map((doc) => AppNotificationModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      throw AppException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw AppException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsRef.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw AppException('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserDeviceToken({
    required String userId,
    required String deviceId,
    required String token,
    required String platform,
  }) async {
    try {
      final docRef = _userDevicesRef.doc(deviceId);
      await docRef.set({
        'id': deviceId,
        'userId': userId,
        'token': token,
        'platform': platform,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw AppException('Failed to save device token: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateDeviceToken({
    required String userId,
    required String deviceId,
  }) async {
    try {
      await _userDevicesRef.doc(deviceId).update({'isActive': false});
    } catch (e) {
      throw AppException('Failed to deactivate device token: ${e.toString()}');
    }
  }
}
