import 'package:authentication_repository/authentication_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:megaspice/app/app.dart';

class App extends StatelessWidget {
  const App(
      {Key? key, required AuthenticationRepository authenticationRepository, required bool onboardingFinished})
      : _authenticationRepository = authenticationRepository,
        _onboardingFinished = onboardingFinished,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  final bool _onboardingFinished;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationRepository: _authenticationRepository,
          onboardingFinished: _onboardingFinished,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FlowBuilder<AppState>(
      state: context.select((AppBloc bloc) => bloc.state),
      onGeneratePages: onGenerateAppViewPages,
    ));
  }
}
