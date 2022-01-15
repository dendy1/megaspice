import 'package:authentication_repository/authentication_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/config/bloc_observer.dart';
import 'package:megaspice/cubit/like_post_cubit/like_post_cubit.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/home/screens/comment/bloc/comment_bloc.dart';
import 'package:megaspice/screens/home/screens/create_post/cubit/create_post_cubit.dart';
import 'package:megaspice/screens/home/screens/profile/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/blocs.dart';
import 'config/custom_router.dart';
import 'screens/auth/login/cubit/login_cubit.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authRepo = AuthRepo();
  await authRepo.user.first;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? onboardingFinished = prefs.getBool("onboardingFinished");

  BlocOverrides.runZoned(
    () => runApp(MyApp(
      authenticationRepository: authRepo,
      onboardingFinished: onboardingFinished ?? false,
    )),
    blocObserver: AppBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp(
      {Key? key,
      required AuthRepo authenticationRepository,
      required bool onboardingFinished})
      : authRepo = authenticationRepository,
        onboardingFinished = onboardingFinished,
        super(key: key);

  final bool onboardingFinished;
  final AuthRepo authRepo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepo>(
          create: (_) => UserRepo(),
        ),
        RepositoryProvider<AuthRepo>(
          create: (_) => AuthRepo(),
        ),
        RepositoryProvider<StorageRepo>(
          create: (_) => StorageRepo(),
        ),
        RepositoryProvider<PostRepo>(
          create: (_) => PostRepo(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepo: authRepo,
              onboardingFinished: onboardingFinished,
            ),
          ),
          BlocProvider<LoginCubit>(
            create: (context) => LoginCubit(
              authRepo,
              context.read<UserRepo>(),
            ),
          ),
          BlocProvider<LikePostCubit>(
            create: (context) => LikePostCubit(
              postRepository: context.read<PostRepo>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              authBloc: context.read<AuthBloc>(),
              postRepo: context.read<PostRepo>(),
              userRepo: context.read<UserRepo>(),
              likePostCubit: context.read<LikePostCubit>(),
            ),
          ),
          BlocProvider<CommentBloc>(
            create: (context) => CommentBloc(
              authBloc: context.read<AuthBloc>(),
              postRepo: context.read<PostRepo>(),
            ),
          ),
          BlocProvider<CreatePostCubit>(
            create: (context) => CreatePostCubit(
                authBloc: context.read<AuthBloc>(),
                postRepo: context.read<PostRepo>(),
                storageRepo: context.read<StorageRepo>()),
          ),
          BlocProvider<EditProfileCubit>(
            create: (context) => EditProfileCubit(
                userRepo: context.read<UserRepo>(),
                storageRepo: context.read<StorageRepo>(),
                profileBloc: context.read<ProfileBloc>()),
          ),
        ],
        child: MaterialApp(
          title: "MegaSpice",
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(),
          navigatorObservers: [
            BotToastNavigatorObserver(),
          ],
          onGenerateRoute: CustomRoute.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
