import 'package:flutter/material.dart';
import 'package:megaspice/feed/feed_list.dart';

class FeedBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(child: FeedList())
      ],
    );
  }
}
