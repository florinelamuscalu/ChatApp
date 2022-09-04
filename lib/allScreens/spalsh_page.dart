//import 'dart:html';

import 'package:chat_app/allConstants/constants.dart';
import 'package:chat_app/allProvider/auth_provider.dart';
import 'package:chat_app/allScreens/home_page.dart';
import 'package:chat_app/allScreens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLogedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LogInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/splash.png",
            width: 300,
            height: 300,
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            'Chat App',
            style: TextStyle(color: ColorConstants.themeColor),
          ),
          const SizedBox(
            height: 30,
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: ColorConstants.themeColor),
          )
        ],
      )),
    );
  }
}
