import 'package:flutter/widgets.dart';
import 'package:megaspice/app/bloc/app_bloc.dart';
import 'package:megaspice/login/login.dart';
import 'package:megaspice/onboarding/onboarding_page.dart';
import 'package:megaspice/posts/posts.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [PostsPage.page()];
    case AppStatus.unauthenticated:
      return [OnboardingPage.page(), PostsPage.page()];
    default:
      return [PostsPage.page()];
  }
}