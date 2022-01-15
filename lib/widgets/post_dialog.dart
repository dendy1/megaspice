import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/blocs/post_bloc/post_cubit.dart';
import 'package:megaspice/cubit/cubits.dart';
import 'package:megaspice/models/models.dart';

class PostScreenArgs {
  final PostModel post;
  final bool isLiked;

  PostScreenArgs({required this.post, required this.isLiked});
}

class PostScreen extends StatefulWidget {
  static const String routeName = "/post";

  static Route route({required PostScreenArgs args}) {
    return MaterialPageRoute(
      settings: RouteSettings(name: PostScreen.routeName),
      builder: (context) => BlocProvider<PostCubit>(
        create: (context) => PostCubit(
          likePostCubit: context.read<LikePostCubit>(),
          post: args.post,
          isLiked: args.isLiked,
        ),
        child: PostScreen(),
      ),
    );
  }

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PostCubit, PostState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.post.author.username ?? "" + " photo"),
            centerTitle: true,
            actions: [],
          ),
          body: Dialog(
              child: Stack(
            children: [
              CachedNetworkImage(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                imageUrl: state.post.imageUrl,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: IconButton(
                    onPressed: () {
                      context.read<PostCubit>().likePost();
                    },
                    icon: state.isLiked
                        ? const Icon(Icons.favorite, color: Colors.red)
                        : const Icon(Icons.favorite_outline),
                    iconSize: 60.0,
                  ),
                ),
              )
            ],
          )),
        );
      }),
    );
  }
}
