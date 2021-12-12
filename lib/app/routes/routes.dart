import 'package:flutter/widgets.dart';
import 'package:megaspice/app/bloc/app_bloc.dart';
import 'package:megaspice/feed/feed.dart';
import 'package:megaspice/login/view/login_page.dart';
import 'package:megaspice/onboarding/onboarding.dart';

List<Page> onGenerateAppViewPages(AppState state, List<Page<dynamic>> pages) {
  switch (state.status) {
    case AppStatus.onboarding:
      return [OnboardingPage.page()];
    case AppStatus.authenticated:
      return [FeedPage.page(false)];
    case AppStatus.unauthenticated:
      return [FeedPage.page(true)];
    default:
      return [LoginPage.page()];
  }
}