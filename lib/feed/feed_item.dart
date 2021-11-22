import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // User Info
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
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
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Text(
                    "borodin_a_o",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.more_horiz_outlined),
                iconSize: 36.0,
              )
            ],
          ),
        ),
        // Image
        Flexible(
            fit: FlexFit.loose,
            child: Image.network("https://picsum.photos/1500/1000")),
        // Like/Comment buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () => {},
                icon: const Icon(FontAwesomeIcons.heart),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(FontAwesomeIcons.comment),
                iconSize: 30.0,
              )
            ],
          ),
        ),
        // Post Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
              Text(
                "borodin_a_o",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                "Some beautiful pictures",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        // Post Date
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Text(
            "2 days ago",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // Post Last Comment
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
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
        // Divider
        const Divider(
          height: 0,
          thickness: 2,
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }
}
