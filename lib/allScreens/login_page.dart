import 'package:chat_app/allProvider/auth_provider.dart';
import 'package:chat_app/allWidgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/allScreens/home_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authentificateError:
        Fluttertoast.showToast(msg: "Sing in Fail");
        break;
      case Status.authentificateCanceled:
        Fluttertoast.showToast(msg: "Sing in canceled");
        break;
      case Status.authentificated:
        Fluttertoast.showToast(msg: "Sing in succes");
        break;
      default:
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset('assets/images/back.png'),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () async {
                bool isSuccess = await authProvider.handeleSingIN();
                if (isSuccess) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                  return;
                }
              },
              child: Image.asset("assets/images/google_login.jpg"),
            ),
          ),
          Stack(children: [
            Positioned(
              child: authProvider.status == Status.authentificating
                  ? const LoadingView()
                  : const SizedBox.shrink(),
            ),
          ]),
        ],
      ),
    );
  }
}
