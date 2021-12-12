import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

import '../feed.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const _postLimit = 20;
const _throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({required this.httpClient}) : super(const FeedState()) {
    on<PostFetched>(_onPostFetched,
        transformer: throttleDroppable(_throttleDuration));
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
      PostFetched event, Emitter<FeedState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == FeedStatus.initial) {
        final posts = await _fetchPosts();
        return emit(state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          hasReachedMax: false,
        ));
      }

      final posts = await _fetchPosts(state.posts.length);
      emit(posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: FeedStatus.success,
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false));
    } catch (ex) {
      print(ex);
      emit(state.copyWith(status: FeedStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final responce = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/photos',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );

    if (responce.statusCode == 200) {
      final body = json.decode(responce.body) as List;
      return body.map((dynamic json) {
        return Post(
          id: json['id'].toString(),
          title: json['title'] as String,
          imageUrl: json['url'] as String,
        );
      }).toList();
    }

    throw Exception('error fetching posts');
  }
}
