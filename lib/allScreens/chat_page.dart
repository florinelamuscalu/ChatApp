import 'dart:io';

import 'package:chat_app/AllModels/message_chat.dart';
import 'package:chat_app/allConstants/constants.dart';
import 'package:chat_app/allConstants/firestore_constants.dart';
import 'package:chat_app/allProvider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../allProvider/chat_provider.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  const ChatPage(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname})
      : super(key: key);

  @override
  State createState() => ChatPageState(
        peerId: this.peerId,
        peerAvatar: this.peerAvatar,
        peerNickname: this.peerNickname,
      );
}

class ChatPageState extends State<ChatPage> {
  ChatPageState(
      {Key? Key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname});

  String peerId;
  String peerAvatar;
  String peerNickname;
  late String currentUserId;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);

  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit = _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogInPage()),
          (Route<dynamic> route) => false);
    }
    if (currentUserId.hashCode <= peerId.hashCode) {
      groupChatId = '$currentUserId-$peerId';
    }

    chatProvider.updateFirestore(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: peerId});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String filename = DateTime.now().microsecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, filename);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(
          content, type, groupChatId, currentUserId, peerId);
      listScrollController.animateTo(0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Nothing to send", backgroundColor: ColorConstants.greyColor);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateFirestore(
        FirestoreConstants.pathMessageCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  void _callPhoneNumber(String callPhoneNumber) async {
    var url = 'tel://$callPhoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildSticker() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi1.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi2.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi3.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi4', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi4.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi5.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi6.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi7', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi7.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi8.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', TypeMessage.stiker),
                  child: Image.asset(
                    "assets/images/mimi9.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: ColorConstants.greyColor2,
              width: 0.5,
            ),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(5),
        height: 180,
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.camera_enhance),
                onPressed: getImage,
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.face_retouching_natural),
                onPressed: getSticker,
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text);
                },
                style: const TextStyle(
                  color: ColorConstants.primaryColor,
                  fontSize: 15,
                ),
                controller: textEditingController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message ...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, TypeMessage.text),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ColorConstants.greyColor2, width: 0.5),
          ),
          color: Colors.white),
    );
  }

  Widget buidItem(int index, DocumentSnapshot? document){
    if(document != null){
      MessageChat messageChat = MessageChat.fromDocument(document);
      if(messageChat.idFrom == currentUserId){
        return Row(
          children: <Widget>[
            messageChat.type == TypeMessage.text
            ? Container(
              child: Text(
                messageChat.content,
                style: const TextStyle(
                  color: ColorConstants.primaryColor,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(
                color: ColorConstants.greyColor2,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index)? 20: 10, right: 10),
            ): messageChat.type == TypeMessage.image
            ?Container(
              child: OutlinedButton(
                child: Material(
                  child: Image.network(
                    messageChat.content,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                      if(loadingProgress == null) return child;
                      return Container(
                        decoration: const BoxDecoration(
                          color: ColorConstants.greyColor2,
                          borderRadius: BorderRadius.all(Radius.circular(8),
                          ),
                        ),
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                            value: loadingProgress.expectedTotalBytes!= null &&
                            loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            :null,
                            ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace){
                      return Material(
                        child: Image.asset(
                          'assets/images/img_not_available.jpeg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                      );
                    },
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                ),
                onPressed: (){},
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))
                ),
              ),
              margin:  EdgeInsets.only(bottom: isLastMessageRight(index)? 20:10, right: 10),
            ): Container(
              child: Image.asset(
                'assets/images/${messageChat.content}.gif',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index)? 20:10, right: 10),
            ),
          ],
        );
      }
    }else{
      return const SizedBox.shrink();
    }
  }


  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage.addAll(snapshot.data!.docs);
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }




}
