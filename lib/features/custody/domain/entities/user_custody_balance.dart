class UserCustodyBalance {
  final String userId;
  final String userName;
  final int totalCollected;
  final int totalReceived;
  final int totalHandedOver;
  final int totalDeposited;
  final int pendingOutgoing;
  final bool isTreasurer;

  const UserCustodyBalance({
    required this.userId,
    required this.userName,
    required this.totalCollected,
    required this.totalReceived,
    required this.totalHandedOver,
    required this.totalDeposited,
    this.pendingOutgoing = 0,
    this.isTreasurer = false,
  });

  /// Cash currently held in person by this member/treasurer (Confirmed)
  int get currentCustody =>
      (totalCollected + totalReceived - (totalHandedOver + totalDeposited)).clamp(0, 100000000);

  /// Available custody after accounting for in-flight pending handovers
  int get availableForHandover =>
      (currentCustody - pendingOutgoing).clamp(0, currentCustody);

  bool get hasActiveCustody => currentCustody > 0;
  bool get hasPendingOutgoing => pendingOutgoing > 0;
}
