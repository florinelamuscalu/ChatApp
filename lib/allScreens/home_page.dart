import 'package:chat_app/allConstants/color_constants.dart';
import 'package:chat_app/allProvider/auth_provider.dart';
import 'package:chat_app/allScreens/login_page.dart';
import 'package:chat_app/allScreens/settings_page.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../AllModels/popup_choices.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollControler = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;


  late String curentUserId;
  late AuthProvider authProvider;
  //late HomeProvider homeProvider;

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Sign out', icon: Icons.exit_to_app),
  ];

  Future<void> handleSingOut() async{
    authProvider.handleSingOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LogInPage()));
  }

  void scrollListener(){
    if(listScrollControler.offset >= listScrollControler.position.maxScrollExtent && !listScrollControler.position.outOfRange){
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPress (PopupChoices choice){
    if (choice.title == "Sing out"){
      handleSingOut();
    }else{
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  Widget buildPopupMenu(){
    return PopupMenuButton <PopupChoices>(
      icon:  const Icon(Icons.more_vert, color: Colors.grey,),
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context){
      return choices.map((PopupChoices choice){
        return PopupMenuItem<PopupChoices>
        (value: choice,
        child: Row(
          children: <Widget>[
          Icon(
            choice.icon,
            color: ColorConstants.primaryColor,
            ),
            Container(
              width: 10,
            ),
              Text(
                choice.title,
                style: const TextStyle(
                  color: ColorConstants.primaryColor
                  ),
              ),
        ],
        ),
        );
      }).toList();
      });
}

  @override
  void initState(){
    super.initState();
    authProvider = context.read<AuthProvider>();
    //homeProvider = context.read<HomeProvider>();

    if(authProvider.getUserFirebaseId()?.isNotEmpty == true){
      curentUserId = authProvider.getUserFirebaseId()!;
    }else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LogInPage()),
      (Route<dynamic> route) => false);
    }
    listScrollControler.addListener(scrollListener);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
          backgroundColor: isWhite ? Colors.white : Colors.black,
          leading: IconButton(
            icon: Switch(
              value: isWhite,
              onChanged: (value){
                setState(() {
                  isWhite = value;
                  print(isWhite);
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              inactiveThumbColor: Colors.black45,
            ),
            onPressed: () => '',
          ),
          actions:<Widget> [
            buildPopupMenu(),
          ],
          ),
    );
  }
}
