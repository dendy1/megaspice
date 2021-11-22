// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:megaspice/feed/feed.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feed',
      theme: ThemeData(
          primaryColor: Colors.black,
          primaryTextTheme:
              const TextTheme(headline6: TextStyle(color: Colors.black)),
          primaryIconTheme: const IconThemeData(color: Colors.black),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xfff8faf8),
              titleTextStyle: TextStyle(color: Colors.black),
              iconTheme: IconThemeData(color: Colors.black)),
          bottomAppBarTheme: const BottomAppBarTheme(

          )),
      home: Home(),
    );
  }
}
