import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:megaspice/repositories/repositories.dart';
import 'package:megaspice/screens/auth/sign_up/sign_up_screen.dart';

import 'cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/login";

  static Route route() {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (context, __, ___) => BlocProvider<LoginCubit>(
        create: (context) =>
            LoginCubit(context.read<AuthRepo>(), context.read<UserRepo>()),
        child: LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, loginState) {
        if (loginState.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content:
                  Text(loginState.errorMessage ?? 'Authentication Failure'),
            ));
        }
      },
      builder: (context, loginState) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: WillPopScope(
              onWillPop: () async => false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EmailInput(),
                        const SizedBox(height: 24.0),
                        _PasswordInput(),
                        const SizedBox(height: 24.0),
                        _SignInButton(),
                        const SizedBox(height: 32.0),
                        _SignUpGoogleButton(),
                        const SizedBox(height: 32.0),
                        Divider(
                          thickness: 2,
                        ),
                        const SizedBox(height: 24.0),
                        const Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            fontFamily: 'Roboto',
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        _SignUpButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) =>
              context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            contentPadding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            label: Text(
              'Enter your email',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color.fromRGBO(153, 153, 153, 1),
                fontFamily: 'Roboto',
                fontSize: 14,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
            ),
            labelStyle: TextStyle(color: Colors.grey[500]),
            errorText: state.email.invalid ? 'Invalid email' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(width: 2.0),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            label: Text(
              'Enter your password',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Color.fromRGBO(153, 153, 153, 1),
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal),
            ),
            labelStyle: TextStyle(color: Colors.grey[500]),
            errorText: state.email.invalid ? 'Invalid password' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(width: 5.0),
            ),
          ),
        );
      },
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity, // <-- match_parent
                height: 45.0,
                child: ElevatedButton(
                  child: Text("Sign In", style: TextStyle(fontSize: 14)),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(178, 7, 118, 184)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(4.0),
                  ),
                  onPressed: state.status.isValidated
                      ? () => context.read<LoginCubit>().logInWithCredentials()
                      : null,
                ));
      },
    );
  }
}

class _SignUpGoogleButton extends StatelessWidget {
  const _SignUpGoogleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45.0,
      child: SignInButton(
        Buttons.Google,
        text: "Sign up with Google",
        onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
        elevation: 4.0,
        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity, // <-- match_parent
        height: 45.0,
        child: ElevatedButton(
          child: Text("Create account", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromRGBO(145, 170, 184, 1)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            elevation: MaterialStateProperty.all<double>(4.0),
          ),
          onPressed: () => {
            Navigator.of(context).pushNamed(SignUpScreen.routeName),
          },
        ));
  }
}
