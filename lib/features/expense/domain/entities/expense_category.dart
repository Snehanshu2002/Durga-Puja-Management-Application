class ExpenseCategory {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int usageCount;

  const ExpenseCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.usageCount = 0,
  });

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    int? usageCount,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  static List<ExpenseCategory> get defaultCategories => const [
        ExpenseCategory(id: 'decoration', name: 'Decoration & Pandal', usageCount: 0),
        ExpenseCategory(id: 'sound', name: 'Sound & Lighting', usageCount: 0),
        ExpenseCategory(id: 'food_prasad', name: 'Food & Prasad', usageCount: 0),
        ExpenseCategory(id: 'tent', name: 'Tent & Infrastructure', usageCount: 0),
        ExpenseCategory(id: 'puja_material', name: 'Puja Materials & Samagri', usageCount: 0),
        ExpenseCategory(id: 'electricity', name: 'Electricity & Generator', usageCount: 0),
        ExpenseCategory(id: 'transport', name: 'Transport & Logistics', usageCount: 0),
        ExpenseCategory(id: 'cleaning', name: 'Cleaning & Sanitation', usageCount: 0),
        ExpenseCategory(id: 'security', name: 'Security & Safety', usageCount: 0),
        ExpenseCategory(id: 'advertisement', name: 'Advertisement & Banners', usageCount: 0),
        ExpenseCategory(id: 'other', name: 'Other Miscellaneous', usageCount: 0),
      ];
}
