import 'package:flutter/widgets.dart';
import 'package:megaspice/app/bloc/app_bloc.dart';
import 'package:megaspice/login/login.dart';
import 'package:megaspice/posts/posts.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [PostsPage.page()];
    case AppStatus.unauthenticated:
    default:
      return [LoginPage.page()];
  }
}