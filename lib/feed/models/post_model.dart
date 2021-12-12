import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String title;
  final String imageUrl;

  const Post({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  Post copyWith({
    required String id,
    required String title,
    required String imageUrl,
  }) {
    return new Post(
      id: id,
      title: title,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object> get props => [id, title, imageUrl];
}
