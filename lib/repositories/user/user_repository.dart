import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megaspice/constants/firebase_constants.dart';
import 'package:megaspice/repositories/repositories.dart';

class UserRepo extends BaseUserRepo {
  final FirebaseFirestore _firebaseFirestore;

  UserRepo({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> setupUser({
    required User? user,
  }) async {
    if (user == null) {
      return;
    }
    _firebaseFirestore.collection(FirebaseConstants.users).doc(user.uid).set(
          user.toDocument(),
        );
  }

  @override
  Future<User> getUserWithId({
    required String userId,
  }) async {
    final doc = await _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(userId)
        .get();
    return doc.exists ? User.fromDocument(doc) : User.empty;
  }

  @override
  Future<void> updateUser({
    required User? user,
  }) async {
    if (user == null) {
      return;
    }

    await _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(user.uid)
        .update(
          user.toDocument(),
        );
  }

  @override
  Future<List<User>> searchUsers({
    required String query,
  }) async {
    final userCollection = FirebaseConstants.users;
    final userSnap = await _firebaseFirestore
        .collection(userCollection)
        .where("username", isGreaterThanOrEqualTo: query)
        .get();
    return userSnap.docs
        .map((queryDocSnap) => User.fromDocument(queryDocSnap))
        .toList();
  }

  @override
  void followUser({
    required String userId,
    required String followUserId,
  }) async {
    final followers = FirebaseConstants.followers;
    final following = FirebaseConstants.following;
    final userFollowers = FirebaseConstants.userFollowers;
    final userFollowing = FirebaseConstants.userFollowing;

    /// add followUser to user's collection
    _firebaseFirestore
        .collection(following)
        .doc(userId)
        .collection(userFollowing)
        .doc(followUserId)
        .set({});

    /// add current user to followUser's userFollowers.
    _firebaseFirestore
        .collection(followers)
        .doc(followUserId)
        .collection(userFollowers)
        .doc(userId)
        .set({});

    final userRef =
        _firebaseFirestore.collection(FirebaseConstants.users).doc(userId);
    final userDoc = await userRef.get();
    userRef.update({
      "following": userDoc.get("following") + 1,
    });

    final followUserRef = _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(followUserId);
    final followUserDoc = await followUserRef.get();
    followUserRef.update({
      "followers": followUserDoc.get("followers") + 1,
    });

    // Feed Logic
    final followUserPostsRef = _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .where('author', isEqualTo: followUserRef);
    final userFeedRef = _firebaseFirestore
        .collection(FirebaseConstants.feeds)
        .doc(userId)
        .collection(FirebaseConstants.userFeed);

    await followUserPostsRef.snapshots().forEach((querySnap) =>
        querySnap.docs.forEach((e) => {userFeedRef.doc(e.id).set(e.data())}));
  }

  @override
  void unfollowUser({
    required String userId,
    required String unfollowUserId,
  }) async {
    final followers = FirebaseConstants.followers;
    final following = FirebaseConstants.following;
    final userFollowers = FirebaseConstants.userFollowers;
    final userFollowing = FirebaseConstants.userFollowing;

    /// remove unfollowing user from user's userFollowing
    _firebaseFirestore
        .collection(following)
        .doc(userId)
        .collection(userFollowing)
        .doc(unfollowUserId)
        .delete();

    /// remove user from unfollowUser's usersFollowers.
    _firebaseFirestore
        .collection(followers)
        .doc(unfollowUserId)
        .collection(userFollowers)
        .doc(userId)
        .delete();

    final userRef =
        _firebaseFirestore.collection(FirebaseConstants.users).doc(userId);
    final userDoc = await userRef.get();
    userRef.update({
      "following":
          userDoc.get("following") - 1 < 0 ? 0 : userDoc.get("following") - 1,
    });

    final followUserRef = _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(unfollowUserId);
    final followUserDoc = await followUserRef.get();
    followUserRef.update({
      "followers": followUserDoc.get("followers") - 1 < 0
          ? 0
          : followUserDoc.get("followers") - 1,
    });

    // Feed Logic
    final userFeedSnapshots = await _firebaseFirestore
        .collection(FirebaseConstants.feeds)
        .doc(userId)
        .collection(FirebaseConstants.userFeed)
        .where('author', isEqualTo: followUserRef).get();

    userFeedSnapshots.docs.forEach((element) {
      if (element.exists) {
        element.reference.delete();
      }
    });
  }

  @override
  Future<bool> isFollowing({
    required String userId,
    required String otherUserId,
  }) async {
    // final followers = FirebaseCollectionConstants.followers;
    final following = FirebaseConstants.following;
    // final userFollowers = FirebaseCollectionConstants.userFollowers;
    final userFollowing = FirebaseConstants.userFollowing;

    /// is otherUser in user's userFollowing
    final otherUserDoc = await _firebaseFirestore
        .collection(following)
        .doc(userId)
        .collection(userFollowing)
        .doc(otherUserId)
        .get();
    return otherUserDoc.exists;
  }

  @override
  Stream<List<User>> getAllFirebaseUsers() {
    return _firebaseFirestore
        .collection(FirebaseConstants.users)
        .snapshots()
        .map(
          (querySnap) => querySnap.docs
              .map((queryDocSnap) => User.fromDocument(queryDocSnap))
              .toList(),
        );
  }
}
