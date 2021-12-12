import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../feed.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                    "https://eu.ui-avatars.com/api/?name=Andrei+Borodin"))),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "borodin_a_o",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  IconButton(
                    onPressed: () => {},
                    icon: Icon(Icons.more_horiz_outlined),
                    iconSize: 36.0,
                  )
                ],
              ),
            ),
            Flexible(
                fit: FlexFit.loose, child: Image.network('${post.imageUrl}')),
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () => {},
                    icon: Icon(FontAwesomeIcons.heart),
                    iconSize: 30.0,
                  ),
                  IconButton(
                    onPressed: () => {},
                    icon: Icon(FontAwesomeIcons.comment),
                    iconSize: 30.0,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    Text(
                      "borodin_a_o",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(child: Column(
                    children: [
                      Text(
                        '${post.title}',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      )
                    ],
                  )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                "2 days ago",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "another_user",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "Nice picture!",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0,
              thickness: 2,
              indent: 0,
              endIndent: 0,
            ),
          ],
        ),
    );
  }
}
