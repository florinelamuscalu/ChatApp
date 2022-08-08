import 'package:chat_app/allConstants/app_constants.dart';
import 'package:chat_app/allConstants/color_constants.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: const IconThemeData(
          color: ColorConstants.primaryColor,
          ),
          title: const Text(
              AppConstants.settingsTitle,
              style: TextStyle(
                  color: ColorConstants.primaryColor,
              ),
              ),
              centerTitle: true,
          ),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({ Key? key }) : super(key: key);

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
