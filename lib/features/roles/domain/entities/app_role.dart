enum AppRole {
  superAdmin('super_admin', 'Super Admin'),
  president('president', 'President'),
  treasurer('treasurer', 'Treasurer'),
  manager('manager', 'Manager'),
  collectionMember('collection_member', 'Collection Member'),
  viewer('viewer', 'Viewer');

  final String id;
  final String label;

  const AppRole(this.id, this.label);

  String get displayName => label;
  bool get isSuperAdmin => this == AppRole.superAdmin;

  static AppRole fromId(String? id) {
    return AppRole.values.firstWhere(
      (role) => role.id == id,
      orElse: () => AppRole.viewer,
    );
  }
}
