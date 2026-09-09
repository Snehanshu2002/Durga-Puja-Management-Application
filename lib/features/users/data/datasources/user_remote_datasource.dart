import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel?> getUserById(String uid);
  Future<UserModel?> getUserByEmail(String email);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String uid);
  Future<List<UserModel>> getAllUsers();
  Stream<List<UserModel>> watchAllUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl(this._firestore);

  CollectionReference get _usersRef => _firestore.collection('users');

  @override
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _usersRef
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _usersRef.doc(user.uid).update(user.toFirestore());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    final docs = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    docs.sort((a, b) => a.name.compareTo(b.name));
    return docs;
  }

  @override
  Stream<List<UserModel>> watchAllUsers() {
    return _usersRef.snapshots().map((snapshot) {
      final docs = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      docs.sort((a, b) => a.name.compareTo(b.name));
      return docs;
    });
  }
}
