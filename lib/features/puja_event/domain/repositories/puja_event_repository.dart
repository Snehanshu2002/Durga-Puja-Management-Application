import '../entities/puja_event.dart';

abstract class PujaEventRepository {
  Future<List<PujaEvent>> getAllEvents();
  Future<List<PujaEvent>> getActiveEvents();
  Future<PujaEvent?> getEventById(String id);
  Future<void> createEvent(PujaEvent event);
  Future<void> updateEvent(PujaEvent event);
}
