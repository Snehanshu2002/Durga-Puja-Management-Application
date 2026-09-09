class CommitteeSettings {
  final String id;
  final String committeeName;
  final String address;
  final String contactNumber;
  final String email;
  final String? logoUrl;
  final String defaultCurrency;
  final DateTime updatedAt;
  final String updatedBy;

  const CommitteeSettings({
    required this.id,
    required this.committeeName,
    required this.address,
    required this.contactNumber,
    required this.email,
    this.logoUrl,
    required this.defaultCurrency,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory CommitteeSettings.defaultSettings() {
    return CommitteeSettings(
      id: 'default',
      committeeName: 'Durga Puja Management Committee',
      address: 'Kolkata, West Bengal, India',
      contactNumber: '+91 98765 43210',
      email: 'info@durgapuja.org',
      defaultCurrency: 'INR',
      updatedAt: DateTime.now(),
      updatedBy: 'system',
    );
  }
}
