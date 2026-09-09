import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../data/datasources/puja_event_remote_datasource.dart';
import '../../data/repositories/puja_event_repository_impl.dart';
import '../../domain/entities/puja_event.dart';
import '../../domain/repositories/puja_event_repository.dart';

final pujaEventDataSourceProvider = Provider<PujaEventRemoteDataSource>((ref) {
  return PujaEventRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final pujaEventRepositoryProvider = Provider<PujaEventRepository>((ref) {
  final dataSource = ref.watch(pujaEventDataSourceProvider);
  return PujaEventRepositoryImpl(dataSource);
});

final pujaEventsProvider = FutureProvider<List<PujaEvent>>((ref) async {
  final repository = ref.watch(pujaEventRepositoryProvider);

  final requiredSeedEvents = [
    PujaEvent(
      id: 'bhasani_utsab_2026',
      name: 'Bhasani Utsab',
      year: 2026,
      eventType: 'BHASANI_UTSAB',
      organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
      startDate: DateTime(2026, 10, 15),
      endDate: DateTime(2026, 10, 20),
      location: 'Main Puja Pandal',
      description: 'Annual Bhasani Utsab 2026',
      status: 'ACTIVE',
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PujaEvent(
      id: 'opera_jatra_2025',
      name: 'Opera / Jatra',
      year: 2025,
      eventType: 'OPERA_JATRA',
      organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
      startDate: DateTime(2025, 10, 1),
      endDate: DateTime(2025, 10, 10),
      location: 'Youth Association Ground',
      description: 'Opera / Jatra Festival 2025',
      status: 'ACTIVE',
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PujaEvent(
      id: 'opera_jatra_2026',
      name: 'Opera / Jatra',
      year: 2026,
      eventType: 'OPERA_JATRA',
      organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 10),
      location: 'Youth Association Ground',
      description: 'Opera / Jatra Festival 2026',
      status: 'ACTIVE',
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  try {
    try {
      await FirebaseFirestore.instance.collection('puja_events').doc('event_2026').delete();
    } catch (_) {}

    for (final seed in requiredSeedEvents) {
      try {
        await repository.createEvent(seed);
      } catch (_) {}
    }

    final events = await repository.getAllEvents();
    if (events.isNotEmpty) {
      final filteredEvents = events.where((e) => e.id != 'event_2026').toList();
      return filteredEvents.isNotEmpty ? filteredEvents : requiredSeedEvents;
    }
  } catch (e) {
    // Return standard seed events if Firestore is still syncing or offline
  }

  return requiredSeedEvents;
});

final userAssignedEventsProvider = FutureProvider<List<PujaEvent>>((ref) async {
  final allEvents = await ref.watch(pujaEventsProvider.future);
  final user = ref.watch(currentUserProvider).value;

  if (user == null || user.role.isSuperAdmin) return allEvents;

  final assigned = allEvents.where((e) => user.hasAccessToEvent(e.id)).toList();
  return assigned.isNotEmpty ? assigned : allEvents;
});

class ActivePujaEventNotifier extends StateNotifier<PujaEvent?> {
  ActivePujaEventNotifier() : super(null);

  void selectEvent(PujaEvent? event) {
    state = event;
  }

  void syncWithEvents(List<PujaEvent> events) {
    if (events.isNotEmpty) {
      if (state == null || !events.any((e) => e.id == state!.id)) {
        state = events.first;
      }
    } else {
      state = null;
    }
  }
}

final activePujaEventProvider =
    StateNotifierProvider<ActivePujaEventNotifier, PujaEvent?>((ref) {
  final notifier = ActivePujaEventNotifier();
  
  final initialEvents = ref.watch(userAssignedEventsProvider).value;
  if (initialEvents != null && initialEvents.isNotEmpty) {
    notifier.syncWithEvents(initialEvents);
  }

  ref.listen<AsyncValue<List<PujaEvent>>>(userAssignedEventsProvider, (previous, next) {
    next.whenData((events) {
      notifier.syncWithEvents(events);
    });
  });
  return notifier;
});
