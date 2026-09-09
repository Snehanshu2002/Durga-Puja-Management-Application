import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/collection_remote_datasource.dart';
import '../../data/repositories/collection_repository_impl.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/repositories/collection_repository.dart';
import '../../../puja_event/presentation/providers/puja_event_provider.dart';

final collectionRemoteDataSourceProvider = Provider<CollectionRemoteDataSource>((ref) {
  return CollectionRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final dataSource = ref.watch(collectionRemoteDataSourceProvider);
  return CollectionRepositoryImpl(dataSource);
});

final collectionsProvider = StreamProvider<List<CollectionEntity>>((ref) async* {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) {
    yield [];
    return;
  }

  try {
    final repo = ref.watch(collectionRepositoryProvider);
    final collections = await repo.getCollectionsByEventId(activeEvent.id);
    yield collections;
  } catch (e) {
    yield [];
  }
});

final pendingCollectionsProvider = StreamProvider<List<CollectionEntity>>((ref) async* {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) {
    yield [];
    return;
  }

  try {
    final repo = ref.watch(collectionRepositoryProvider);
    final pending = await repo.getPendingCollections(activeEvent.id);
    yield pending;
  } catch (e) {
    yield [];
  }
});
