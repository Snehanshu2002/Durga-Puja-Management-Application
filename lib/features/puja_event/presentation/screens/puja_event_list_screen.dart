import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/puja_event_provider.dart';
import 'add_edit_puja_event_screen.dart';

class PujaEventListScreen extends ConsumerWidget {
  const PujaEventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(pujaEventsProvider);
    final user = ref.watch(currentUserProvider).value;
    final permissionService = PermissionService();
    final canManageEvents = user != null &&
        permissionService.hasPermission(user.role, Permission.managePujaEvents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puja Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Events',
            onPressed: () {
              ref.invalidate(pujaEventsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Events refreshed!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No Puja events found.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (canManageEvents) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditPujaEventScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Puja Event'),
                    ),
                  ],
                ],
              ),
            );
          }

          final dateFormat = DateFormat('dd MMM');

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pujaEventsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        StatusChip(status: event.status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)} (${event.year})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (event.location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(event.location),
                            ],
                          ),
                        ],
                      ],
                    ),
                    onTap: canManageEvents
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditPujaEventScreen(event: event),
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingView(message: 'Loading events...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(pujaEventsProvider),
        ),
      ),
      floatingActionButton: canManageEvents
          ? FloatingActionButton(
              heroTag: 'puja_events_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditPujaEventScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
