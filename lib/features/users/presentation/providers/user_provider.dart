import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/core/utils/dev_seeder.dart';
import 'package:durgapuja_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});

final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final demoUser = ref.watch(demoUserProvider);
  if (demoUser != null) {
    yield demoUser;
    return;
  }

  final authStream = fb_auth.FirebaseAuth.instance.authStateChanges();
  await for (final fbUser in authStream) {
    final currentDemoUser = ref.watch(demoUserProvider);
    if (currentDemoUser != null) {
      yield currentDemoUser;
    } else if (fbUser == null) {
      yield null;
    } else {
      try {
        final userRepo = ref.watch(userRepositoryProvider);
        AppUser? appUser = await userRepo.getUserById(fbUser.uid);

        if (appUser == null && AppEnvironment.isDev) {
          await DevBootstrapSeeder.seedDevEnvironment(fbUser);
          appUser = await userRepo.getUserById(fbUser.uid);
        }

        if (appUser == null && fbUser.email != null && fbUser.email!.isNotEmpty) {
          final userByEmail = await userRepo.getUserByEmail(fbUser.email!);
          if (userByEmail != null && userByEmail.uid != fbUser.uid) {
            final migrated = userByEmail.copyWith(
              uid: fbUser.uid,
              updatedAt: DateTime.now(),
            );
            await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set(
              (migrated as UserModel).toFirestore(),
              SetOptions(merge: true),
            );
            await userRepo.deleteUser(userByEmail.uid);
            appUser = migrated;
          }
        }

        if (appUser != null) {
          yield appUser;
        } else {
          final role = _getRoleFromEmail(fbUser.email ?? '');
          yield AppUser(
            uid: fbUser.uid,
            name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
            email: fbUser.email ?? 'user@durgapuja.org',
            role: role,
            status: 'ACTIVE',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: 'system',
          );
        }
      } catch (e) {
        final role = _getRoleFromEmail(fbUser.email ?? '');
        yield AppUser(
          uid: fbUser.uid,
          name: fbUser.email?.split('@').first ?? 'User',
          email: fbUser.email ?? 'user@durgapuja.org',
          role: role,
          status: 'ACTIVE',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        );
      }
    }
  }
});

final effectiveRoleProvider = Provider<AppRole>((ref) {
  final user = ref.watch(currentUserProvider).value;
  final activeEvent = ref.watch(activePujaEventProvider);
  if (user == null) return AppRole.viewer;
  return user.getEffectiveRoleForEvent(activeEvent?.id);
});

AppRole _getRoleFromEmail(String email) {
  final lower = email.toLowerCase();
  if (lower.contains('president')) return AppRole.president;
  if (lower.contains('treasurer')) return AppRole.treasurer;
  if (lower.contains('manager')) return AppRole.manager;
  if (lower.contains('collector') || lower.contains('collection')) return AppRole.collectionMember;
  if (lower.contains('viewer')) return AppRole.viewer;
  return AppRole.superAdmin;
}

final userNamesMapProvider = FutureProvider<Map<String, String>>((ref) async {
  final Map<String, String> map = {
    'admin': 'Super Admin',
    'system': 'System Admin',
  };
  try {
    final users = await ref.read(userRepositoryProvider).getAllUsers();
    for (final u in users) {
      final label = '${u.name} (${u.role.displayName})';
      map[u.uid] = label;
      if (u.email.isNotEmpty) {
        final lowerEmail = u.email.toLowerCase();
        map[lowerEmail] = label;
        final prefix = lowerEmail.split('@').first;
        map[prefix] = label;
        map['user_pre_$prefix'] = label;
      }
    }
  } catch (_) {}
  return map;
});

final activeEventMembersProvider = FutureProvider<List<AppUser>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];
  try {
    final allUsers = await ref.read(userRepositoryProvider).getAllUsers();
    return allUsers
        .where((u) => u.isActive && u.hasAccessToEvent(activeEvent.id))
        .toList();
  } catch (_) {
    return [];
  }
});
