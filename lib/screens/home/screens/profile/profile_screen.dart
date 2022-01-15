import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/blocs.dart';
import 'package:megaspice/cubit/like_post_cubit/like_post_cubit.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/widgets/widgets.dart';

import 'widgets/widgets.dart';

class ProfileScreenArgs {
  final String userId;

  ProfileScreenArgs({required this.userId});
}

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile";

  static Route route({
    required ProfileScreenArgs args,
  }) {
    return MaterialPageRoute(
      settings: RouteSettings(name: ProfileScreen.routeName),
      builder: (context) => BlocProvider<ProfileBloc>(
        create: (_) => ProfileBloc(
          userRepo: context.read<UserRepo>(),
          authBloc: context.read<AuthBloc>(),
          postRepo: context.read<PostRepo>(),
          likePostCubit: context.read<LikePostCubit>(),
        )..add(ProfileLoadEvent(userId: args.userId)),
        child: ProfileScreen(),
      ),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, profileState) {
        if (profileState.status == ProfileStatus.failure) {
          //closing the existing dialog if exits during loading
          Navigator.of(context, rootNavigator: true).pop();
          BotToast.closeAllLoading();
          BotToast.showText(text: profileState.failure.message);
          //showing the error dialog if error exists
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Error signing in",
                message: profileState.failure.message,
              );
            },
          );
        }
      },
      builder: (context, profileState) {
        return _buildBody(profileState);
      },
    );
  }

  Widget _buildBody(ProfileState profileState) {
    switch (profileState.status) {
      case ProfileStatus.loading:
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text(profileState.user.username ?? "no username"),
            centerTitle: true,
            actions: [
              if (profileState.isCurrentUser != null && profileState.isCurrentUser!)
                IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequestedEvent());
                    context.read<LikePostCubit>().clearAllLikedPost();
                  },
                  icon: Icon(Icons.exit_to_app),
                )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ProfileBloc>()
                  .add(ProfileLoadEvent(userId: profileState.user.uid));
              await Future.delayed(
                Duration(milliseconds: 500),
              );
              return; //true return will remove refresh indicator go away
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            UserProfileImage(
                              radius: 40,
                              profileImageURL: profileState.user.photo,
                            ),
                            ProfileInfo(
                              fullName: profileState.user.displayName ??
                                  "",
                              gender: profileState.user.gender ??
                                  "",
                              dateOfBirth: profileState.user.dateOfBirth == null ? "" : profileState.user.dateOfBirth.toString(),
                            ),
                            ProfileStats(
                              isCurrentUser: profileState.isCurrentUser,
                              isFollowing: profileState.isFollowing,
                              posts: profileState.posts.length,
                              followers: profileState.user.followers ?? 0,
                              following: profileState.user.following ?? 0,
                            ),
                          ],
                        ),
                        SizedBox(height: 16,),
                        Divider(
                          height: 0,
                          thickness: 2,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = profileState.posts[index];
                      if (post == null) {
                        return null;
                      }
                      final likedPostState =
                          context.watch<LikePostCubit>().state;
                      final isLiked =
                          likedPostState.likedPostIds.contains(post.id);
                      return PostView(
                        post: post,
                        isLiked: isLiked,
                        onLike: () {
                          if (isLiked) {
                            context
                                .read<LikePostCubit>()
                                .unLikePost(postModel: post);
                          } else {
                            context
                                .read<LikePostCubit>()
                                .likePost(postModel: post);
                          }
                        },
                      );
                    },
                    childCount: profileState.posts.length,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
