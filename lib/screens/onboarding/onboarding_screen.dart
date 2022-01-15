import 'dart:io';
import 'package:flutter/material.dart';
import 'package:megaspice/screens/home/screens/navbar/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/onboarding_screen_data.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = "/onboarding";

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: OnboardingScreen.routeName),
      builder: (_) => OnboardingScreen(),
    );
  }

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final List<OnboardingScreenData> sliders;
  int currentIndex = 0;
  PageController pageController = new PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    sliders = getSliders();
  }

  Widget pageIndexIndicator(bool isCurrent) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: isCurrent ? 15.0 : 7.5,
      width: isCurrent ? 15.0 : 7.5,
      decoration: BoxDecoration(
        color: isCurrent
            ? Color(0xFF0190C4).withAlpha(190)
            : Colors.grey.withAlpha(190),
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
  }

  void _persistOnboarding() async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setBool("onboardingFinished", true);
    Navigator.pushReplacement(context, NavBar.route());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: PageView.builder(
            controller: pageController,
            itemCount: sliders.length,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemBuilder: (context, index) {
              return SliderTile(
                imageAssetPath: sliders[index].imagePath,
                title: sliders[index].title,
                description: sliders[index].description,
              );
            },
          ),
        ),
        bottomSheet: currentIndex != sliders.length - 1
            ? Container(
                height: Platform.isIOS ? 90.0 : 80.0,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Color(0xFFD4EBF4)),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              primary: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              pageController.animateToPage(sliders.length - 1,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linearToEaseOut);
                              setState(() {
                                currentIndex = sliders.length - 1;
                              });
                            },
                            child: const Text("Skip"),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        for (int i = 0; i < sliders.length; i++)
                          pageIndexIndicator(i == currentIndex)
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Color(0xFF00C468)),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              primary: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              pageController.animateToPage(currentIndex + 1,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linearToEaseOut);
                              setState(() {
                                currentIndex = currentIndex + 1;
                              });
                            },
                            child: const Text("Next"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            : ClipRRect(
                child: Stack(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      transformAlignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: Platform.isIOS ? 70.0 : 60.0,
                      color: Color(0xFF0190C4).withAlpha(255),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          primary: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _persistOnboarding();
                        },
                        child: SizedBox.expand(
                          child: Center(
                              child: Text(
                            "GET STARTED NOW!",
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class SliderTile extends StatelessWidget {
  SliderTile(
      {required this.imageAssetPath,
      required this.title,
      required this.description});

  String imageAssetPath, title, description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 36),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imageAssetPath),
          SizedBox(
            height: 20.0,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333)),
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
                color: Color(0xFF333333)),
          )
        ],
      ),
    );
  }
}
