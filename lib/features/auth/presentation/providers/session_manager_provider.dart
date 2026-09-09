import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/services/session_service.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import 'auth_provider.dart';

final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

final forcedLogoutMessageProvider = StateProvider<String?>((ref) => null);

class SessionManager {
  final Ref ref;
  StreamSubscription<DocumentSnapshot>? _userSnapshotSubscription;
  Timer? _heartbeatTimer;
  String? _currentMonitoredUid;
  String? _activeLocalSessionId;
  bool _isProcessingLogout = false;

  SessionManager(this.ref);

  String? get activeLocalSessionId => _activeLocalSessionId;

  /// Register session upon successful login.
  Future<String> registerNewSessionOnLogin({
    required String uid,
    required String name,
    required String email,
  }) async {
    _isProcessingLogout = false;
    final sessionService = ref.read(sessionServiceProvider);
    final newSessionId = sessionService.generateSecureSessionId();
    _activeLocalSessionId = newSessionId;

    await sessionService.saveLocalSessionId(newSessionId);

    final platformName = sessionService.getPlatformName();
    final now = DateTime.now();

    // Update Firestore document securely
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userDocRef.set({
      'activeSessionId': newSessionId,
      'lastActiveAt': Timestamp.fromDate(now),
      'isOnline': true,
      'sessionUpdatedAt': Timestamp.fromDate(now),
      'lastPlatform': platformName,
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    // Create LOGIN audit log record
    await _writeAuditLog(
      userId: uid,
      userName: name,
      action: AuditLog.actionLogin,
      entityType: 'SESSION',
      entityId: newSessionId,
      metadata: {
        'email': email,
        'platform': platformName,
        'sessionId': newSessionId,
      },
    );

    // Start real-time snapshot listener and heartbeat
    startSessionMonitoring(uid: uid, initialSessionId: newSessionId);

    return newSessionId;
  }

  /// Start observing current user document via Firestore `snapshots()`.
  void startSessionMonitoring({
    required String uid,
    required String initialSessionId,
  }) {
    if (_currentMonitoredUid == uid && _userSnapshotSubscription != null) {
      return;
    }

    stopSessionMonitoring();
    _currentMonitoredUid = uid;
    if (_activeLocalSessionId == null || _activeLocalSessionId!.isEmpty) {
      if (initialSessionId.isNotEmpty) {
        _activeLocalSessionId = initialSessionId;
      }
    }
    _isProcessingLogout = false;

    // Start heartbeat
    _startHeartbeat(uid);

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    _userSnapshotSubscription = userDocRef.snapshots().listen(
      (snapshot) async {
        if (_isProcessingLogout) return;

        if (!snapshot.exists || snapshot.data() == null) {
          await _triggerForcedLogout(
            uid: uid,
            reason: 'Your account access has been revoked.',
            isSessionReplaced: false,
            action: AuditLog.actionForcedLogout,
          );
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final status = (data['status'] as String?) ?? 'ACTIVE';
        final remoteSessionId = data['activeSessionId'] as String?;

        // 1. Account status check: ACTIVE vs DEACTIVATED / REMOVED / INACTIVE
        if (status.toUpperCase() != 'ACTIVE') {
          await _triggerForcedLogout(
            uid: uid,
            reason: 'Your account access has been revoked.',
            isSessionReplaced: false,
            action: status.toUpperCase() == 'REMOVED'
                ? AuditLog.actionUserAssociationRemoved
                : AuditLog.actionUserDeactivated,
          );
          return;
        }

        // 2. Session ID check: Universal Single-Device Login enforcement
        String? localSessionId = _activeLocalSessionId;
        if (localSessionId == null || localSessionId.isEmpty) {
          localSessionId = await ref.read(sessionServiceProvider).getLocalSessionId();
        }

        // Auto-recover local session ID on browser tab refresh/reload if local session is empty
        if ((localSessionId == null || localSessionId.isEmpty) && remoteSessionId != null && remoteSessionId.isNotEmpty) {
          _activeLocalSessionId = remoteSessionId;
          await ref.read(sessionServiceProvider).saveLocalSessionId(remoteSessionId);
          localSessionId = remoteSessionId;
        }

        if (localSessionId != null &&
            localSessionId.isNotEmpty &&
            remoteSessionId != null &&
            remoteSessionId.isNotEmpty &&
            remoteSessionId != localSessionId) {
          await _triggerForcedLogout(
            uid: uid,
            reason: 'Your account was logged in on another device.',
            isSessionReplaced: true,
            action: AuditLog.actionSessionReplaced,
          );
          return;
        }
      },
      onError: (error) {
        debugPrint('Session snapshot monitoring stream error (handled gracefully): $error');
        // Do not force logout solely on network error (Requirement 14)
      },
    );
  }

  /// Start periodic heartbeat to maintain online status without excessive writes.
  void _startHeartbeat(String uid) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (_) async {
      if (_isProcessingLogout) return;
      await sendHeartbeat(uid);
    });
  }

  /// Send heartbeat update if local session matches active session in Firestore.
  Future<void> sendHeartbeat(String uid) async {
    try {
      final localSessionId = _activeLocalSessionId ?? await ref.read(sessionServiceProvider).getLocalSessionId();
      if (localSessionId == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data();
      final remoteSessionId = data?['activeSessionId'] as String?;

      if (remoteSessionId == localSessionId && (data?['status'] ?? 'ACTIVE').toString().toUpperCase() == 'ACTIVE') {
        final platformName = ref.read(sessionServiceProvider).getPlatformName();
        final now = DateTime.now();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'lastActiveAt': Timestamp.fromDate(now),
          'isOnline': true,
          'lastPlatform': platformName,
        });
      }
    } catch (e) {
      debugPrint('Heartbeat update error (temporary network fluctuation): $e');
      // Network loss must not immediately log user out (Requirement 14)
    }
  }

  /// Handle forced logout when session is replaced or account is deactivated/removed.
  Future<void> _triggerForcedLogout({
    required String uid,
    required String reason,
    required bool isSessionReplaced,
    required String action,
  }) async {
    if (_isProcessingLogout) return;
    _isProcessingLogout = true;

    stopSessionMonitoring();

    // Fetch user name for audit log if possible
    String userName = 'User';
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        userName = currentUser.name;
      }
    } catch (_) {}

    // Only update Firestore if session was NOT replaced by another device (Requirement 9)
    if (!isSessionReplaced) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isOnline': false,
          'activeSessionId': null,
          'lastActiveAt': Timestamp.fromDate(DateTime.now()),
        });
      } catch (e) {
        debugPrint('Error updating offline state on forced logout: $e');
      }
    }

    // Write audit log entry
    await _writeAuditLog(
      userId: uid,
      userName: userName,
      action: action,
      entityType: 'SESSION',
      entityId: uid,
      metadata: {
        'reason': reason,
        'isSessionReplaced': isSessionReplaced,
      },
    );

    // Clear local session storage
    await ref.read(sessionServiceProvider).clearLocalSessionId();
    _activeLocalSessionId = null;

    // Set forced logout banner message for UI display
    ref.read(forcedLogoutMessageProvider.notifier).state = reason;

    // Sign out Firebase Authentication
    try {
      await fb_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out Firebase Auth: $e');
    }

    ref.read(demoUserProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
  }

  /// Handle user-initiated normal logout.
  Future<void> performNormalLogout(AppUser currentUser) async {
    if (_isProcessingLogout) return;
    _isProcessingLogout = true;

    final localSessionId = _activeLocalSessionId ?? await ref.read(sessionServiceProvider).getLocalSessionId();

    stopSessionMonitoring();

    // Requirement 9: Check if local session is still active before modifying Firestore
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        final remoteSessionId = doc.data()?['activeSessionId'] as String?;
        if (remoteSessionId == localSessionId) {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'isOnline': false,
            'activeSessionId': null,
            'lastActiveAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating user logout state in Firestore: $e');
    }

    // Write LOGOUT audit log entry
    await _writeAuditLog(
      userId: currentUser.uid,
      userName: currentUser.name,
      action: AuditLog.actionLogout,
      entityType: 'SESSION',
      entityId: localSessionId ?? currentUser.uid,
      metadata: {
        'email': currentUser.email,
      },
    );

    // Clear local session
    await ref.read(sessionServiceProvider).clearLocalSessionId();
    _activeLocalSessionId = null;

    // Sign out Firebase Auth
    try {
      await fb_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error during firebase sign out: $e');
    }

    ref.read(demoUserProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
    _isProcessingLogout = false;
  }

  /// Stop active session monitoring and timer.
  void stopSessionMonitoring() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _userSnapshotSubscription?.cancel();
    _userSnapshotSubscription = null;
    _currentMonitoredUid = null;
  }

  /// Write audit log helper method.
  Future<void> _writeAuditLog({
    required String userId,
    required String userName,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final auditRepo = ref.read(auditRepositoryProvider);
      final log = AuditLog(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
        eventId: 'global',
        userId: userId,
        userName: userName,
        action: action,
        entityType: entityType,
        entityId: entityId,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      await auditRepo.logAction(log);
    } catch (e) {
      debugPrint('Failed to write audit log: $e');
    }
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref);
});
