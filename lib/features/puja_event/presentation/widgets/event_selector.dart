import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import '../providers/puja_event_provider.dart';

class EventSelector extends ConsumerWidget {
  const EventSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userAssignedEventsProvider);
    final activeEvent = ref.watch(activePujaEventProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'No Assigned Events',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          );
        }

        final selectedId = (activeEvent != null && events.any((e) => e.id == activeEvent.id))
            ? activeEvent.id
            : events.first.id;

        return Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.accentLight, size: 20),
              isDense: true,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              selectedItemBuilder: (BuildContext context) {
                return events.map<Widget>((event) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      '${event.name} (${event.year})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList();
              },
              onChanged: (String? newId) {
                if (newId != null) {
                  final selected = events.firstWhere((e) => e.id == newId);
                  ref.read(activePujaEventProvider.notifier).selectEvent(selected);
                }
              },
              items: events.map((event) {
                final isSelected = selectedId == event.id;
                return DropdownMenuItem<String>(
                  value: event.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.organizationName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${event.name} ${event.year}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
