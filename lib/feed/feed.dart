import 'package:flutter/material.dart';
import 'package:megaspice/feed/feed_body.dart';

class Home extends StatelessWidget {
  final topBar = AppBar(
    centerTitle: true,
    elevation: 1.0,
    title: const Text(
      'MegaSpice',
    ),
  );

  final bottomBar = Container(
    color: Colors.white,
    height: 75.0,
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
              iconSize: 34.0,),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_box_outlined),
              iconSize: 34.0,),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.accessible_forward_rounded),
              iconSize: 34.0,)
          ],
        ),
      )
      ,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topBar, body: FeedBody(), bottomNavigationBar: bottomBar);
  }
}
