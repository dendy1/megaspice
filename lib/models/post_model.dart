import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:megaspice/constants/firebase_constants.dart';

import 'models.dart';

class PostModel extends Equatable {
  final String? id;
  final String caption;
  final String imageUrl;
  final User author;
  final int likes;
  final int comments;
  final DateTime dateTime;

  const PostModel({
    this.id,
    required this.caption,
    required this.imageUrl,
    required this.author,
    required this.likes,
    required this.comments,
    required this.dateTime,
  });

  PostModel copyWith({
    String? id,
    String? caption,
    String? imageUrl,
    User? author,
    int? likes,
    int? comments,
    DateTime? dateTime,
  }) {
    return new PostModel(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object> get props => [caption, imageUrl, author, likes, comments, dateTime];

  Map<String, dynamic> toDocuments() {
    final authorDocsRef = FirebaseFirestore.instance.collection(FirebaseConstants.users).doc(author.uid);
    return {
      'caption': caption,
      'imageUrl': imageUrl,
      'author': authorDocsRef,
      'likes': likes,
      'comments': comments,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  static Future<PostModel?> fromDocument(DocumentSnapshot doc) async {
    final authorRef = doc.get("author") as DocumentReference;
    final authorDoc = await authorRef.get();
    if (authorDoc.exists) {
      return PostModel(
        id: doc.id,
        caption: doc.get("caption") ?? "",
        imageUrl: doc.get("imageUrl") ?? "",
        author: User.fromDocument(authorDoc),
        likes: (doc["likes"] ?? 0).toInt(),
        comments: (doc["comments"] ?? 0).toInt(),
        dateTime: (doc.get("dateTime") as Timestamp).toDate(),
      );
    }
    return null;
  }
}
