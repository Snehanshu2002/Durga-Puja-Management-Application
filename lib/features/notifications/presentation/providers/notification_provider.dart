import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/entities/app_notification.dart';
import '../../../users/presentation/providers/user_provider.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final userNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final ds = ref.watch(notificationRemoteDataSourceProvider);
  return await ds.getUserNotifications(user.uid);
});
