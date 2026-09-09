import '../entities/user.dart';

abstract class UserRepository {
  Future<AppUser?> getUserById(String uid);
  Future<AppUser?> getUserByEmail(String email);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<void> deleteUser(String uid);
  Future<List<AppUser>> getAllUsers();
  Stream<List<AppUser>> watchAllUsers();
}
