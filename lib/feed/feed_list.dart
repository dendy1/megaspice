import 'package:flutter/material.dart';
import 'package:megaspice/feed/feed_item.dart';

class FeedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 5, itemBuilder: (context, index) => const FeedItem());
  }
}
