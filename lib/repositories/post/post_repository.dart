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
    required PostModel post,
  }) async {
    final authorRef = _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(post.author.uid);
    authorRef.update({"posts": FieldValue.increment(1)});

    final createdPostRef = await _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .add(
          post.toDocuments(),
        );
    final createPostData = await createdPostRef.get();

    if (createPostData != null) {
      final userFollowerRef = _firebaseFirestore
          .collection(FirebaseConstants.followers)
          .doc(post.author.uid)
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
    } else {
      authorRef.update({"posts": FieldValue.increment(-1)});
    }
  }

  @override
  Future<void> deletePost({
    required PostModel post,
  }) async {
    await _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .doc(post.id)
        .delete();

    final authorRef = _firebaseFirestore
        .collection(FirebaseConstants.users)
        .doc(post.author.uid);
    authorRef.update({"posts": FieldValue.increment(-1)});

    final userFollowerRef = _firebaseFirestore
        .collection(FirebaseConstants.followers)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userFollowers);

    final userFollowerSnapshot = await userFollowerRef.get();
    userFollowerSnapshot.docs.forEach((element) async {
      if (element.exists) {
        await _firebaseFirestore
            .collection(FirebaseConstants.feeds)
            .doc(element.id)
            .collection(FirebaseConstants.userFeed)
            .doc(post.id)
            .delete();
      }
    });

    await _firebaseFirestore
        .collection(FirebaseConstants.feeds)
        .doc(FirebaseConstants.guestFeed)
        .collection(FirebaseConstants.userFeed)
        .doc(post.id)
        .delete();
  }

  @override
  Future<void> createComment({
    required PostModel post,
    required CommentModel comment,
  }) async {
    await _firebaseFirestore
        .collection(FirebaseConstants.comments)
        .doc(comment.postId)
        .collection(FirebaseConstants.postComments)
        .add(
          comment.toDocuments(),
        );

    await _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .doc(post.id)
        .update({"comments": FieldValue.increment(1)});

    final userFollowerRef = _firebaseFirestore
        .collection(FirebaseConstants.followers)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userFollowers);

    final userFollowerSnapshot = await userFollowerRef.get();
    userFollowerSnapshot.docs.forEach((element) {
      if (element.exists) {
        _firebaseFirestore
            .collection(FirebaseConstants.feeds)
            .doc(element.id)
            .collection(FirebaseConstants.userFeed)
            .doc(post.id)
            .update({"comments": FieldValue.increment(1)});
      }
    });

    _firebaseFirestore
        .collection(FirebaseConstants.feeds)
        .doc(FirebaseConstants.guestFeed)
        .collection(FirebaseConstants.userFeed)
        .doc(post.id)
        .update({"comments": FieldValue.increment(1)});
  }

  @override
  Future<void> deleteComment({
    required PostModel post,
    required CommentModel comment,
  }) async {
    await _firebaseFirestore
        .collection(FirebaseConstants.comments)
        .doc(comment.postId)
        .collection(FirebaseConstants.postComments)
        .doc(comment.id)
        .delete();

    await _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .doc(post.id)
        .update({"comments": FieldValue.increment(-1)});

    final userFollowerRef = _firebaseFirestore
        .collection(FirebaseConstants.followers)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userFollowers);

    final userFollowerSnapshot = await userFollowerRef.get();
    userFollowerSnapshot.docs.forEach((element) {
      if (element.exists) {
        _firebaseFirestore
            .collection(FirebaseConstants.feeds)
            .doc(element.id)
            .collection(FirebaseConstants.userFeed)
            .doc(post.id)
            .update({"comments": FieldValue.increment(-1)});
      }
    });

    _firebaseFirestore
        .collection(FirebaseConstants.feeds)
        .doc(FirebaseConstants.guestFeed)
        .collection(FirebaseConstants.userFeed)
        .doc(post.id)
        .update({"comments": FieldValue.increment(-1)});
  }

  @override
  Future<List<PostModel?>> getUserPosts({
    required String userId,
    String? lastPostId,
  }) async {
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.posts)
          .doc(userId)
          .collection(FirebaseConstants.userPosts)
          .orderBy("dateTime", descending: true)
          .limit(FirebaseConstants.postToLoad)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(FirebaseConstants.posts)
          .doc(userId)
          .collection(FirebaseConstants.userPosts)
          .doc(lastPostId)
          .get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.posts)
          .doc(userId)
          .collection(FirebaseConstants.userPosts)
          .orderBy("dateTime", descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(FirebaseConstants.postToLoad)
          .get();
    }

    final futurePostList = Future.wait(
        postsSnap.docs.map((post) => PostModel.fromDocument(post)).toList());
    return futurePostList;
  }

  Stream<List<Future<PostModel?>>> getUserPostsStream({
    required String userId,
    String? lastPostId,
  }) {
    if (lastPostId == null) {
      return _firebaseFirestore
          .collection(FirebaseConstants.posts)
          .doc(userId)
          .collection(FirebaseConstants.userPosts)
          .orderBy("dateTime", descending: true)
          .limit(FirebaseConstants.postToLoad)
          .limit(FirebaseConstants.postToLoad)
          .snapshots()
          .map(
            (querySnap) => querySnap.docs
                .map(
                  (queryDocSnap) => PostModel.fromDocument(queryDocSnap),
                )
                .toList(),
          );
    } else {
      final lastPostDoc = _firebaseFirestore
          .collection(FirebaseConstants.posts)
          .doc(userId)
          .collection(FirebaseConstants.userPosts)
          .doc(lastPostId)
          .get();

      lastPostDoc.then((doc) {
        return _firebaseFirestore
            .collection(FirebaseConstants.posts)
            .doc(userId)
            .collection(FirebaseConstants.userPosts)
            .orderBy("dateTime", descending: true)
            .startAfterDocument(doc)
            .limit(FirebaseConstants.postToLoad)
            .snapshots()
            .map(
              (querySnap) => querySnap.docs
              .map(
                (queryDocSnap) => PostModel.fromDocument(queryDocSnap),
          )
              .toList(),
        );
      });
    }

    return _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(userId)
        .collection(FirebaseConstants.userPosts)
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
  Stream<List<Future<CommentModel?>>> getPostCommentsStream(
      {required String postId}) {
    return _firebaseFirestore
        .collection(FirebaseConstants.comments)
        .doc(postId)
        .collection(FirebaseConstants.postComments)
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

  Future<CommentModel?> getLastPostComment({
    required String postId,
  }) async {
    QuerySnapshot commentsSnap = await _firebaseFirestore
        .collection(FirebaseConstants.comments)
        .doc(postId)
        .collection(FirebaseConstants.postComments)
        .orderBy("dateTime", descending: true)
        .limit(1)
        .get();

    if (commentsSnap.size == 0) {
      return null;
    }

    final futureComment = CommentModel.fromDocument(commentsSnap.docs.first);
    return futureComment;
  }

  @override
  Future<List<PostModel?>> getUserFeed({
    required String userId,
    String? lastPostId,
  }) async {
    //paginating logic
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(userId)
          .collection(FirebaseConstants.userFeed)
          .orderBy("dateTime", descending: true)
          .limit(FirebaseConstants.postToLoad)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(userId)
          .collection(FirebaseConstants.userFeed)
          .doc(lastPostId)
          .get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(FirebaseConstants.feeds)
          .doc(userId)
          .collection(FirebaseConstants.userFeed)
          .orderBy("dateTime", descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(FirebaseConstants.postToLoad)
          .get();
    }

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

    final futurePostList = Future.wait(
        postsSnap.docs.map((post) => PostModel.fromDocument(post)).toList());
    return futurePostList;
  }

  @override
  void createLike({
    required PostModel post,
    required String userId,
  }) async {
    // updating the post doc with likes
    // we use here field value because if we use ("likes" : postModel.likes +1 ) it cannot handle concurrent like case
    _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .doc(post.id)
        .update({"likes": FieldValue.increment(1)});

    // keeping the userId in postLikes Sub collection of like collection with post id
    _firebaseFirestore
        .collection(FirebaseConstants.likes)
        .doc(post.id)
        .collection(FirebaseConstants.postLikes)
        .doc(userId)
        .set({});
  }

  @override
  void deleteLike({
    required PostModel post,
    required String userId,
  }) {
    //decrementing the likes from post document
    _firebaseFirestore
        .collection(FirebaseConstants.posts)
        .doc(post.author.uid)
        .collection(FirebaseConstants.userPosts)
        .doc(post.id)
        .update({"likes": FieldValue.increment(-1)});

    //deleting userId from postLikes collection
    _firebaseFirestore
        .collection(FirebaseConstants.likes)
        .doc(post.id)
        .collection(FirebaseConstants.postLikes)
        .doc(userId)
        .delete();
  }

  @override
  Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<PostModel?> posts,
  }) async {
    final postIds = <String>{};
    for (final post in posts) {
      if (post == null) {
        continue;
      }

      final likedDoc = await _firebaseFirestore
          .collection(FirebaseConstants.likes)
          .doc(post.id)
          .collection(FirebaseConstants.postLikes)
          .doc(userId)
          .get();

      if (likedDoc.exists) {
        postIds.add(post.id!);
      }
    }
    return postIds;
  }
}
