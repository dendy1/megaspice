import 'package:authentication_repository/authentication_repository.dart';

abstract class BaseUserRepo {
  Future<User> getUserWithId({
    required String userId,
  });

  Future<void> setupUser({
    required User user,
  });

  Future<void> updateUser({
    required User user,
  });

  Future<void> disableUser({
    required User user,
  });

  Future<List<User>> searchUsers({
    required String query,
  });

  void followUser({
    required String userId,
    required String followUserId,
  });

  void unfollowUser({
    required String userId,
    required String unfollowUserId,
  });

  Future<bool> isFollowing({
    required String userId,
    required String otherUserId,
  });

  Stream<List<User>> getAllFirebaseUsers();
}
