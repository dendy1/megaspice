import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:megaspice/constants/firebase_constants.dart';

class CommentModel extends Equatable {
  final String? id;
  final String postId;
  final String content;
  final User author;
  final DateTime dateTime;

  const CommentModel({
    this.id,
    required this.postId,
    required this.content,
    required this.author,
    required this.dateTime,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? content,
    User? author,
    DateTime? dateTime,
  }) {
    return new CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      author: author ?? this.author,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object?> get props => [id, postId, content, author, dateTime];

  Map<String, dynamic> toDocuments() {
    final authorId = FirebaseFirestore.instance.collection(FirebaseConstants.users).doc(author.uid);
    return {
      'postId': postId,
      'content': content,
      'author': authorId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  static Future<CommentModel?> fromDocument(DocumentSnapshot doc) async {
    final authorRef = doc.get("author") as DocumentReference;
    final authorDoc = await authorRef.get();
    if (authorDoc.exists) {
      return CommentModel(
        id: doc.id,
        postId: doc.get("postId") ?? "",
        content: doc.get("content") ?? "",
        author: User.fromDocument(authorDoc),
        dateTime: (doc.get("dateTime") as Timestamp).toDate(),
      );
    }
    return null;
  }
}