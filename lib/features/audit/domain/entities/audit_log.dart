class AuditLog {
  static const String actionLogin = 'LOGIN';
  static const String actionLogout = 'LOGOUT';
  static const String actionSessionReplaced = 'SESSION_REPLACED';
  static const String actionForcedLogout = 'FORCED_LOGOUT';
  static const String actionUserDeactivated = 'USER_DEACTIVATED';
  static const String actionUserAssociationRemoved = 'USER_ASSOCIATION_REMOVED';
  static const String actionChandaPdfExport = 'CHANDA_PDF_EXPORT';
  static const String actionChandaCsvExport = 'CHANDA_CSV_EXPORT';
  static const String actionChandaPrint = 'CHANDA_PRINT';
  static const String actionWhatsappShare = 'WHATSAPP_SHARE';
  static const String actionPhoneNumberEdit = 'PHONE_NUMBER_EDIT';
  static const String actionChandaTargetDelete = 'CHANDA_TARGET_DELETE';

  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String action; // 'CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'REJECT', 'ROLE_CHANGE', 'STATUS_CHANGE', 'LOGIN', 'LOGOUT', 'SESSION_REPLACED', 'FORCED_LOGOUT', 'USER_DEACTIVATED', 'USER_ASSOCIATION_REMOVED', 'CHANDA_PDF_EXPORT', 'CHANDA_CSV_EXPORT', 'CHANDA_PRINT', 'WHATSAPP_SHARE', 'PHONE_NUMBER_EDIT'
  final String entityType; // 'COLLECTION', 'EXPENSE', 'EVENT', 'USER', 'SESSION'
  final String entityId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AuditLog({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    this.metadata,
  });
}
