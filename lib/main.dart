import 'package:chatapp/allConstants/app_constants.dart';
import 'package:chatapp/allProvider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
//import 'chatapp_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isWhite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();


  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;


  MyApp({required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(
          firebaseAuth: FirebaseAuth.instance,
          googleSignIn: GoogleSignIn(),
          prefs: this.prefs,
          firebaseFirestore: this.firebaseFirestore
        ))
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor:  Colors.black,
        ),
        home: const Scaffold(),
        debugShowCheckedModeBanner: false,
      ),
    );
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: chatApp()
    // );
  }
  }
