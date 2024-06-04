import 'dart:async';
import 'package:cab_ex/User/home/HomePage.dart';
import 'package:cab_ex/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'User/bottombar/NavigateRedirectScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () async {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) =>  NavigateRedirectScreen()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => registration()));
        }
      },
    );
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/splash2.png'
                ),

            ),
          ),
        ),
      ),
    );;
  }
}
