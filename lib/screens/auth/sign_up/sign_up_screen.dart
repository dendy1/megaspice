import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:megaspice/repositories/repositories.dart';

import 'cubit/sign_up_cubit.dart';

class SignUpScreen extends StatelessWidget {
  static const String routeName = "/sign_up";

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<SignUpCubit>(
          create: (_) => SignUpCubit(
            context.read<AuthRepo>(),
            context.read<UserRepo>(),
          ),
          child: const SignUpForm(),
        ),
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Sign Up Failure')));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 56.0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BackButton(),
                ],
              ),
            ),
            Expanded(child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmailInput(),
                  const SizedBox(height: 24.0),
                  _PasswordInput(),
                  const SizedBox(height: 24.0),
                  _ConfirmPasswordInput(),
                  const SizedBox(height: 32.0),
                  _SignUpButton(),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) =>
              context.read<SignUpCubit>().emailChanged(email),
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
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
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
            errorText: state.password.invalid ? 'Invalid password' : null,
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

class _ConfirmPasswordInput extends StatelessWidget {
  const _ConfirmPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          onChanged: (confirmPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmPassword),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            label: Text(
              'Confirm password',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Color.fromRGBO(153, 153, 153, 1),
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal),
            ),
            labelStyle: TextStyle(color: Colors.grey[500]),
            errorText: state.confirmedPassword.invalid
                ? 'Passwords do not match'
                : null,
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

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            :
        SizedBox(
            width: double.infinity, // <-- match_parent
            height: 48,
            child: ElevatedButton(
              child: Text("Create account", style: TextStyle(fontSize: 14)),
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
                  ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                  : null,
            ));
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity, // <-- match_parent
        height: 48,
        child: TextButton.icon(
          icon: Icon(FontAwesomeIcons.arrowLeft, size: 20.0,),
          label: Text("Return to login screen", style: TextStyle(fontSize: 14)),
          //iconSize: 48.0,
          //child: Text("Return to login screen", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(178, 7, 118, 184)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            elevation: MaterialStateProperty.all<double>(4.0),
          ),
          onPressed: () => Navigator.pop(context),
        ));
  }
}