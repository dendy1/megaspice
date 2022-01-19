import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/auth_bloc/auth_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/config/custom_router.dart';
import 'package:megaspice/cubit/comment_post_cubit/comment_post_cubit.dart';
import 'package:megaspice/cubit/like_post_cubit/like_post_cubit.dart';
import 'package:megaspice/repositories/post/post_repository.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/auth/login/login_screen.dart';
import 'package:megaspice/screens/home/screens/create_post/cubit/create_post_cubit.dart';
import 'package:megaspice/screens/home/screens/feed/bloc/feed_bloc.dart';
import 'package:megaspice/screens/home/screens/navbar/cubit/NavBarCubit.dart';
import 'package:megaspice/screens/home/screens/profile/profile_bloc/profile_bloc.dart';

import '../../screens.dart';

class TabNavigator extends StatelessWidget {
  static const String tabNavigatorRoot = "/";

  final GlobalKey<NavigatorState> navigatorKey;
  final NavBarItem item;

  const TabNavigator({Key? key, required this.navigatorKey, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        key: navigatorKey,
        initialRoute: tabNavigatorRoot,
        onGenerateInitialRoutes: (_, initialRoute) {
          return [
            MaterialPageRoute(
              settings: RouteSettings(name: tabNavigatorRoot),
              builder: (context) => _getScreen(context, item),
            ),
          ];
        },
        onGenerateRoute: CustomRoute.onGenerateNestedRoute,
      ),
      onWillPop: () async => false,
    );
  }

  Widget _getScreen(BuildContext context, NavBarItem item) {
    switch (item) {
      case NavBarItem.feed:
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return BlocProvider(
              create: (context) => FeedBloc(
                postRepo: context.read<PostRepo>(),
                authBloc: context.read<AuthBloc>(),
                likePostCubit: context.read<LikePostCubit>(),
                commentPostCubit: context.read<CommentPostCubit>(),
              )..add(FeedFetchEvent()),
              child: FeedScreen(),
            );
          },
        );

      case NavBarItem.create:
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.unauthenticated ||
                state.status == AuthStatus.unknown) {
              return LoginScreen();
            } else if (state.status == AuthStatus.authenticated) {
              return BlocProvider<CreatePostCubit>(
                create: (context) => CreatePostCubit(
                  authBloc: context.read<AuthBloc>(),
                  postRepo: context.read<PostRepo>(),
                  storageRepo: context.read<StorageRepo>(),
                ),
                child: CreatePostScreen(),
              );
            }
            return Scaffold();
          },
        );

      case NavBarItem.profile:
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.unauthenticated ||
                state.status == AuthStatus.unknown) {
              return LoginScreen();
            } else if (state.status == AuthStatus.authenticated) {
              return BlocProvider<ProfileBloc>(
                create: (_) => ProfileBloc(
                  userRepo: context.read<UserRepo>(),
                  authBloc: context.read<AuthBloc>(),
                  postRepo: context.read<PostRepo>(),
                  likePostCubit: context.read<LikePostCubit>(),
                  commentPostCubit: context.read<CommentPostCubit>(),
                )..add(
                    ProfileLoadEvent(
                      userId: context.read<AuthBloc>().state.user.uid,
                    ),
                  ),
                child: ProfileScreen(),
              );
            }
            return Scaffold();
          },
        );

      default:
        return Scaffold();
    }
  }
}
