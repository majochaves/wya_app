import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameManager{

  Future<void> deleteUsername(String username) async{
    await FirebaseFirestore.instance.collection('usernames').doc(username).delete();
  }

  Future<void> addUsername(String username) async{
    await FirebaseFirestore.instance.collection('usernames').doc(username).set({"username": username});
  }

  Future<bool> usernameIsUnique(String username) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username).get();

    return !doc.exists;
  }
}