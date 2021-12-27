import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:megaspice/app/app.dart';
import 'package:megaspice/login/login.dart';

import '../feed.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key, required bool guest})
      : _guest = guest,
        super(key: key);

  final double _iconSize = 40.0;
  final bool _guest;

  static Page page(bool guest) => MaterialPage<void>(child: FeedPage(guest: guest));

  _buildTopBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 1.0,
      title: const Text(
        'MegaSpice',
      ),
      actions: [
        IconButton(
          key: const Key('homePage_logout_iconButton'),
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => context.read<AppBloc>().add(AppLogoutRequested()),
        )
      ],
    );
  }

  _buildBottomBar(BuildContext context) {
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
                onPressed: () {
                  if (_guest) {
                    context.read<AppBloc>().add(AppLoginRequested());
                  } else {
                    print("Go to user profile page");
                  }
                },
                icon: _guest ? const Icon(Icons.login_outlined) : const Icon(Icons.account_circle_outlined),
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
      appBar: _buildTopBar(context),
      body: BlocProvider(
        create: (_) => FeedBloc(httpClient: http.Client())..add(PostFetched()),
        child: PostsList(),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }
}
