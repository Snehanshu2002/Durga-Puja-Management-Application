import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<AppUser?> getUserById(String uid) async {
    return await _remoteDataSource.getUserById(uid);
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    return await _remoteDataSource.getUserByEmail(email);
  }

  @override
  Future<void> createUser(AppUser user) async {
    final model = UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      mobile: user.mobile,
      role: user.role,
      status: user.status,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      createdBy: user.createdBy,
      activeSessionId: user.activeSessionId,
      lastActiveAt: user.lastActiveAt,
      isOnline: user.isOnline,
      sessionUpdatedAt: user.sessionUpdatedAt,
      lastPlatform: user.lastPlatform,
    );
    await _remoteDataSource.createUser(model);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final model = UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      mobile: user.mobile,
      role: user.role,
      status: user.status,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      createdBy: user.createdBy,
      activeSessionId: user.activeSessionId,
      lastActiveAt: user.lastActiveAt,
      isOnline: user.isOnline,
      sessionUpdatedAt: user.sessionUpdatedAt,
      lastPlatform: user.lastPlatform,
    );
    await _remoteDataSource.updateUser(model);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _remoteDataSource.deleteUser(uid);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    return await _remoteDataSource.getAllUsers();
  }

  @override
  Stream<List<AppUser>> watchAllUsers() {
    return _remoteDataSource.watchAllUsers();
  }
}
