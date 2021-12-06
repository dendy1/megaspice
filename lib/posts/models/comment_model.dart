import 'package:equatable/equatable.dart';
import 'models.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String content;
  final User author;
  final DateTime dateTime;

  const Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.author,
    required this.dateTime,
  });

  Comment copyWith({
    required String id,
    required String postId,
    required String content,
    required User author,
    required DateTime dateTime,
  }) {
    return new Comment(
      id: id,
      postId: postId,
      content: content,
      author: author,
      dateTime: dateTime,
    );
  }

  @override
  List<Object?> get props => [id, postId, content, author, dateTime];
}