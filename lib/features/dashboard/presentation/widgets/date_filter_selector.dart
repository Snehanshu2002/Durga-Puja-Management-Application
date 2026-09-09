import 'package:flutter/material.dart';

enum DashboardDateRange {
  thisPuja('This Puja'),
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  thisMonth('This Month');

  final String label;
  const DashboardDateRange(this.label);
}

class DateFilterSelector extends StatelessWidget {
  final DashboardDateRange selectedRange;
  final ValueChanged<DashboardDateRange> onRangeChanged;

  const DateFilterSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: DashboardDateRange.values.map((range) {
          final isSelected = selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(range.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onRangeChanged(range);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
