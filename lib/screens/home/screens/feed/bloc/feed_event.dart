part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FeedFetchEvent extends FeedEvent {}

class FeedPaginateEvent extends FeedEvent {}

class FeedDeletePostEvent extends FeedEvent {
  final PostModel post;

  FeedDeletePostEvent({
    required this.post,
  });

  @override
  List<Object> get props => [post];
}