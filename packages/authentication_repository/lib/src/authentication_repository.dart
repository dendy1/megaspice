import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/models/failures/disable_user_failure.dart';
import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthRepo {
  /// {@macro authentication_repository}
  AuthRepo({
    CacheClient? cache,
    firebase.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final CacheClient _cache;
  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Whether or not the current environment is web
  /// Should only be overriden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when the authentication state changes.
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read(key: userCacheKey) ?? User.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<User?> signUp({required String email, required String password}) async {
    try {
      var signedInCredentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return signedInCredentials.user!.toUser;
    } on firebase.FirebaseAuthException catch (ex) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(ex.code);
    } catch (ex) {
      throw SignUpWithEmailAndPasswordFailure(ex.toString());
    }
  }

  /// Starts the Sign In with Google Flow.
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<User?> logInWithGoogle() async {
    try {
      late final firebase.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase.GoogleAuthProvider();
        final userCredentials =
            await _firebaseAuth.signInWithPopup(googleProvider);
        credential = userCredentials.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      var signedInCredentials = await _firebaseAuth.signInWithCredential(credential);
      return signedInCredentials.user!.toUser;
    } on firebase.FirebaseAuthException catch (ex) {
      throw LogInWithGoogleFailure.fromCode(ex.code);
    } catch (ex) {
      throw LogInWithGoogleFailure(ex.toString());
    }
  }

  /// Signs in with the provided [email] and [password].
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on firebase.FirebaseAuthException catch (ex) {
      throw LogInWithEmailAndPasswordFailure.fromCode(ex.code);
    } catch (ex) {
      throw LogInWithEmailAndPasswordFailure(ex.toString());
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (ex) {
      throw LogOutFailure(ex.toString());
    }
  }

  Future<void> disableUser() async {
    try {
      await _firebaseAuth.currentUser!.delete();
      await logOut();
    } catch (ex) {
      print(ex.toString());
      throw DisableUserFailure(ex.toString());
    }
  }
}

extension on firebase.User {
  User get toUser {
    return User(uid: uid, email: email, username: email!.split("@")[0],  displayName: displayName, photo: photoURL);
  }
}
