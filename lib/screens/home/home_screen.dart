import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";

  static Route route() {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (_, __, ___) => HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Text("HomeScreen"),
        ),
      ),
    );
  }
}
