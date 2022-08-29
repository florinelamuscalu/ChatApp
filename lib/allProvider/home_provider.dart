import 'package:chat_app/allConstants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeProvider{
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({
    required this.firebaseFirestore
  });

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate){
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFirestore(String pathColletion, int limit, String? textSearch){
    if(textSearch?.isNotEmpty == true){
      return firebaseFirestore.collection(pathColletion).limit(limit).where(FirestoreConstants.nickname, isEqualTo: textSearch).snapshots();
    }else{
return firebaseFirestore.collection(pathColletion).limit(limit).snapshots();
    }
  }
}