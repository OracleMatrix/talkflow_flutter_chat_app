// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:talkflow_chat_app/Pages/root_page.dart';
import 'package:talkflow_chat_app/Provider/firebase_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      body: FlutterLogin(
        logo: "assets/images/logo.png",
        onSignup: (data) async {
          try {
            User? user = await firebaseProvider.firebaseServices
                .signUpWithEmailAndPassword(data.name!, data.password!);
            if (user != null) {
              await firebaseProvider.firestoreService.saveUserData(user.uid, {
                "email": data.name,
                'uid': FirebaseAuth.instance.currentUser!.uid,
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RootPage(),
                  ));
            } else {
              return "Sign up failed!";
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              return 'Sign up failed!\nEmail already exists.';
            } else {
              return 'Sign up failed!\n${e.message}';
            }
          } catch (e) {
            return 'Sign up failed!\nEmail already exists.';
          }
          return null;
        },
        onLogin: (data) async {
          User? user = await firebaseProvider.firebaseServices
              .signInWithEmailAndPassword(data.name, data.password);
          if (user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RootPage(),
              ),
            );
          } else {
            return "Login failed!\nInvalid email or password";
          }
          return null;
        },
        onRecoverPassword: (email) async {
          await firebaseProvider.firebaseServices.sendPasswordResetEmail(email);
          return null;
        },
      ),
    );
  }
}
