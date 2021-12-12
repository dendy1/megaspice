import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:megaspice/app/bloc_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? onboardingFinished = prefs.getBool("onboardingFinished");
  print("Onboarding Finished: " + onboardingFinished.toString());
  BlocOverrides.runZoned(
    () => runApp(App(
      authenticationRepository: authenticationRepository,
      onboardingFinished: onboardingFinished ?? false,
    )),
    blocObserver: AppBlocObserver(),
  );
}
