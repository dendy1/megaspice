import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megaspice/constants/firebase_constants.dart';
import 'package:megaspice/models/models.dart';
import 'package:megaspice/repositories/repositories.dart';

class PostRepo extends BasePostRepo {
  final FirebaseFirestore _firebaseFirestore;

  PostRepo({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({
    required PostModel postModel,
  }) async {
    final createdPostRef =
        await _firebaseFirestore.collection(FirebaseConstants.posts).add(
              postModel.toDocuments(),
            );
    final createPostData = await createdPostRef.get();

    if (createPostData != null) {
      final userFollowerRef = _firebaseFirestore
          .collection(FirebaseConstants.followers)
          .doc(postModel.author.uid)
          .collection(FirebaseConstants.userFollowers);
      final userFollowerSnapshot = await userFollowerRef.get();
      userFollowerSnapshot.docs.forEach((element) {
        if (element.exists) {
          _firebaseFirestore
              .collection(FirebaseConstants.feeds)
              .doc(element.id)
              .collection(FirebaseConstants.userFeed)
              .doc(createdPostRef.id)
              .set(createPostData.data()!);
        }
      });

      _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(FirebaseConstants.guestFeed)
          .collection(FirebaseConstants.userFeed)
          .doc(createdPostRef.id)
          .set(createPostData.data()!);
    }
  }

  @override
  Future<void> createComment({
    required PostModel postModel,
    required CommentModel commentModel,
  }) async {
    final commentCollection = FirebaseConstants.comments;
    final postCommentCollection = FirebaseConstants.postComments;
    await _firebaseFirestore
        .collection(commentCollection)
        .doc(commentModel.postId)
        .collection(postCommentCollection)
        .add(
          commentModel.toDocuments(),
        );
  }

  @override
  Stream<List<Future<PostModel?>>> getUserPosts({
    required String userId,
  }) {
    final userCollection = FirebaseConstants.users;
    final postCollection = FirebaseConstants.posts;
    final authorRef = _firebaseFirestore.collection(userCollection).doc(userId);
    return _firebaseFirestore
        .collection(postCollection)
        .where('author', isEqualTo: authorRef)
        .orderBy("dateTime", descending: true)
        .snapshots()
        .map(
          (querySnap) => querySnap.docs
              .map(
                (queryDocSnap) => PostModel.fromDocument(queryDocSnap),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Future<CommentModel?>>> getPostComment({
    required String postId,
  }) {
    final commentCollection = FirebaseConstants.comments;
    final postCommentsSubCollection = FirebaseConstants.postComments;
    return _firebaseFirestore
        .collection(commentCollection)
        .doc(postId)
        .collection(postCommentsSubCollection)
        .orderBy("dateTime", descending: false)
        .snapshots()
        .map(
          (querySnap) => querySnap.docs
              .map(
                (queryDoc) => CommentModel.fromDocument(
                  queryDoc,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<PostModel?>> getUserFeed({
    required String userId,
    String? lastPostId,
  }) async {
    final feeds = FirebaseConstants.feeds;
    final userFeed = FirebaseConstants.userFeed;
    //paginating logic
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(feeds)
          .doc(userId)
          .collection(userFeed)
          .orderBy("dateTime", descending: true)
          .limit(FirebaseConstants.postToLoad)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(feeds)
          .doc(userId)
          .collection(userFeed)
          .doc(lastPostId)
          .get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(feeds)
          .doc(userId)
          .collection(userFeed)
          .orderBy("dateTime", descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(FirebaseConstants.postToLoad)
          .get();
    }

    // final postSnap = await _firebaseFirestore.collection(feeds).doc(userId).collection(userFeed).orderBy("dateTime", descending: true).get();
    //here if use does not use future.wait we get only List<Future<PostModel>>
    final futurePostList = Future.wait(
        postsSnap.docs.map((post) => PostModel.fromDocument(post)).toList());
    return futurePostList;
  }

  @override
  Future<List<PostModel?>> getGuestFeed({
    String? lastPostId,
  }) async {
    //paginating logic
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(FirebaseConstants.guestFeed)
          .collection(FirebaseConstants.userFeed)
          .orderBy("dateTime", descending: true)
          .limit(FirebaseConstants.postToLoad)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(FirebaseConstants.guestFeed)
          .collection(FirebaseConstants.userFeed)
          .doc(lastPostId)
          .get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(FirebaseConstants.guestFeed)
          .collection(FirebaseConstants.userFeed)
          .orderBy("dateTime", descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(FirebaseConstants.postToLoad)
          .get();
    }

    // final postSnap = await _firebaseFirestore.collection(feeds).doc(userId).collection(userFeed).orderBy("dateTime", descending: true).get();
    //here if use does not use future.wait we get only List<Future<PostModel>>
    final futurePostList = Future.wait(
        postsSnap.docs.map((post) => PostModel.fromDocument(post)).toList());
    return futurePostList;
  }

  @override
  void createLike({
    required PostModel postModel,
    required String userId,
  }) async {
    final likes = FirebaseConstants.likes;
    final postLikes = FirebaseConstants.postLikes;
    final posts = FirebaseConstants.posts;
    //  updating the post doc with likes
    //we use here field value because if we use ("likes" : postModel.likes +1 ) it cannot handle concurrent like case
    _firebaseFirestore
        .collection(posts)
        .doc(postModel.id)
        .update({"likes": FieldValue.increment(1)});
    //keeping the userId in postLikes Sub collection of like collection with post id
    _firebaseFirestore
        .collection(likes)
        .doc(postModel.id)
        .collection(postLikes)
        .doc(userId)
        .set({});
  }

  @override
  void deleteLike({
    required String postId,
    required String userId,
  }) {
    final likes = FirebaseConstants.likes;
    final postLikes = FirebaseConstants.postLikes;
    final posts = FirebaseConstants.posts;
    //decrementing the likes from post document
    _firebaseFirestore
        .collection(posts)
        .doc(postId)
        .update({"likes": FieldValue.increment(-1)});
    //deleting userId from postLikes collection
    _firebaseFirestore
        .collection(likes)
        .doc(postId)
        .collection(postLikes)
        .doc(userId)
        .delete();
  }

  @override
  Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<PostModel?> posts,
  }) async {
    //getting all ids of posts which  the user liked
    final likesCollection = FirebaseConstants.likes;
    final postLikesCollection = FirebaseConstants.postLikes;
    final postIds = <String>{};
    for (final post in posts) {
      if (post == null) {
        continue;
      }

      final likedDoc = await _firebaseFirestore
          .collection(likesCollection)
          .doc(post.id)
          .collection(postLikesCollection)
          .doc(userId)
          .get();
      //getting if userId exists in postLikesCollection if so added that is on postIds SET
      if (likedDoc.exists) {
        postIds.add(post.id!);
      }
    }
    return postIds;
  }
}