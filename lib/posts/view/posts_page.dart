import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../posts.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  final _iconSize = 40.0;

  static Page page() => const MaterialPage<void>(child: PostsPage());

  _buildTopBar() {
    return AppBar(
      centerTitle: true,
      elevation: 1.0,
      title: const Text(
        'MegaSpice',
      ),
    );
  }

  _buildBottomBar() {
    return Container(
      color: Colors.white,
      height: 60.0,
      alignment: Alignment.center,
      child: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home_outlined),
                iconSize: _iconSize,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_box_outlined),
                iconSize: _iconSize,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.accessible_forward_rounded),
                iconSize: _iconSize,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTopBar(),
      body: BlocProvider(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: PostsList(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
