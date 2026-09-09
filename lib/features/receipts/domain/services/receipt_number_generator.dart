class ReceiptNumberGenerator {
  static String formatReceiptNumber(int year, int sequenceNumber) {
    final seqStr = sequenceNumber.toString().padLeft(6, '0');
    return 'DP-$year-$seqStr';
  }
}
