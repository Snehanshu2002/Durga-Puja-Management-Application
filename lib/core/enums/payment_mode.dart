enum PaymentMode {
  cash('CASH', 'Cash'),
  upi('UPI', 'UPI'),
  bankTransfer('BANK_TRANSFER', 'Bank Transfer'),
  cheque('CHEQUE', 'Cheque'),
  other('OTHER', 'Other');

  final String id;
  final String label;

  const PaymentMode(this.id, this.label);

  static PaymentMode fromId(String? id) {
    return PaymentMode.values.firstWhere(
      (m) => m.id == id,
      orElse: () => PaymentMode.cash,
    );
  }
}
