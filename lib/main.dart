// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talkflow_chat_app/Pages/auth_page.dart';
import 'package:talkflow_chat_app/Pages/root_page.dart';
import 'package:talkflow_chat_app/Provider/firebase_provider.dart';
import 'package:talkflow_chat_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseProvider(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      initial: AdaptiveThemeMode.system,
      light: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        iconTheme: const IconThemeData(color: Colors.blue),
        textTheme:
            GoogleFonts.montserratTextTheme().apply(bodyColor: Colors.white),
      ),
      builder: (light, dark) => MaterialApp(
        title: 'TalkFlow',
        theme: light,
        themeMode: ThemeMode.system,
        darkTheme: dark,
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Timer.periodic(
                const Duration(minutes: 5),
                (timer) async {
                  try {
                    await FirebaseAuth.instance.currentUser?.reload();
                    if (FirebaseAuth.instance.currentUser == null) {
                      FirebaseAuth.instance
                          .signOut()
                          .then((value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthPage())))
                          .catchError((error) =>
                              throw Exception("Failed to delete user: $error"));
                    }
                  } catch (e) {
                    throw Exception(e);
                  }
                },
              );
              return const RootPage();
            } else {
              return const AuthPage();
            }
          },
        ),
      ),
    );
  }
}
