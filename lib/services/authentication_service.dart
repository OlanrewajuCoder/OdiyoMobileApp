import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/users_model.dart' as u;
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/screens/auth/set_preferences.dart';
import 'package:odiyo/screens/home/home_page.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/utils/preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();
  final firestoreService = Get.find<FirestoreService>();

  signOut() async {
    await Preferences.setUser('');
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    await GoogleSignIn().signOut();
    Get.offAll(() => const Login());
  }

  signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      u.User user = (await firestoreService.getUserFromEmail(email)).data()!;
      await Preferences.setUser(user.userID!);
      userController.currentUser.value = user;
      Get.offAll(() => HomePage());
    } on FirebaseAuthException catch (e) {
      Get.back();
      showRedAlert(e.message.toString());
    } catch (e) {
      Get.back();
      showRedAlert(e.toString());
    }
  }

  signUp(u.User user, String password) async {
    try {
      if (await firestoreService.checkIfUserExists(user.email!)) {
        showRedAlert('User exists with this email. Try logging in.');
        await signOut();
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email!, password: password);
        user.createdDate = Timestamp.now();
        user.membershipStatus = 'free';
        user.membershipExpiryDate = Timestamp.now();
        await firestoreService.addUser(user);
        await Preferences.setUser(user.userID!);
        userController.currentUser.value = user;
        Get.offAll(() => const SetPreferences());
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      showRedAlert(e.message!);
    } catch (e) {
      Get.back();
      showRedAlert(e.toString());
    }
  }

  void changePassword(String password) async {
    User user = FirebaseAuth.instance.currentUser!;
    user.updatePassword(password).then((_) {
      Get.back();
      showGreenAlert('Password changed');
    }).catchError((error) {
      Get.back();
      showRedAlert('Something went wrong. Please login again and try again');
    });
  }

  resetPassword(String email) async {
    utilService.showLoading();
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    Get.offAll(() => const Login());
    showGreenAlert('Password reset instructions sent to your email');
  }

  signInWithGoogle(bool isLoggingIn) async {
    try {
      utilService.showLoading();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await setUser(isLoggingIn, u.User(userID: const Uuid().v1(), email: userCredential.user!.email, name: userCredential.user!.displayName, photoURL: userCredential.user!.photoURL, token: await getFirebaseToken(), unreadNotifications: false, preferences: []));
    } catch (e) {
      Get.back();
      debugPrint(e.toString());
      await signOut();
      Get.back();
      showRedAlert(e.toString());
    }
  }

  signInWithFacebook(bool isLoggingIn) async {
    try {
      utilService.showLoading();
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential credential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await setUser(isLoggingIn, u.User(userID: const Uuid().v1(), email: userCredential.user!.email, name: userCredential.user!.displayName, photoURL: userCredential.user!.photoURL, token: await getFirebaseToken(), unreadNotifications: false, preferences: []));
    } catch (e) {
      Get.back();
      debugPrint(e.toString());
      await signOut();
      Get.back();
      showRedAlert(e.toString());
    }
  }

  signInWithTwitter(bool isLoggingIn) async {
    try {
      utilService.showLoading();
      final twitterLogin = TwitterLogin(apiKey: '<your consumer key>', apiSecretKey: ' <your consumer secret>', redirectURI: '<your_scheme>://');
      final authResult = await twitterLogin.login();
      final twitterAuthCredential = TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
      await setUser(isLoggingIn, u.User(userID: const Uuid().v1(), email: userCredential.user!.email, name: userCredential.user!.displayName, photoURL: userCredential.user!.photoURL, token: await getFirebaseToken(), unreadNotifications: false, preferences: []));
    } catch (e) {
      Get.back();
      debugPrint(e.toString());
      await signOut();
      Get.back();
      showRedAlert(e.toString());
    }
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple(bool isLoggingIn) async {
    try {
      utilService.showLoading();
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: nonce);
      final oauthCredential = OAuthProvider("apple.com").credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      await setUser(isLoggingIn, u.User(userID: const Uuid().v1(), email: userCredential.user!.email, name: userCredential.user!.email, photoURL: userCredential.user!.photoURL, token: await getFirebaseToken(), unreadNotifications: false, preferences: []));
    } catch (e) {
      Get.back();
      debugPrint(e.toString());
      await signOut();
      Get.back();
      showRedAlert(e.toString());
    }
  }

  setUser(bool isLoggingIn, u.User user) async {
    bool emailExists = await firestoreService.checkIfUserExists(user.email!);
    Get.back(); //Closes the dialog
    if (emailExists) {
      u.User loggedInUser = (await firestoreService.getUserFromEmail(user.email!)).data()!;
      if (isLoggingIn) {
        await Preferences.setUser(loggedInUser.userID!);
        userController.currentUser.value = (await firestoreService.getUser(await Preferences.getUser())).data()!;
        Get.offAll(() => HomePage());
      } else {
        await signOut();
        showRedAlert('User exists with this email. Please login.');
      }
    } else {
      if (isLoggingIn) {
        await signOut();
        showRedAlert('No user with this email. Please sign up.');
      } else {
        await Preferences.setUser(user.userID!);
        user.createdDate = Timestamp.now();
        user.membershipStatus = 'free';
        user.membershipExpiryDate = Timestamp.now();
        await firestoreService.addUser(user);
        userController.currentUser.value = (await firestoreService.getUser(await Preferences.getUser())).data()!;
        Get.offAll(() => const SetPreferences());
      }
    }
  }

  Future<String> getFirebaseToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);
    String? token = await messaging.getToken();
    return token!;
  }
}
