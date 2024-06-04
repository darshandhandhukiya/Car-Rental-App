
import 'package:cab_ex/registration.dart';
import 'package:cab_ex/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Admin/screen/homescreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
