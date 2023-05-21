import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsernameService {

  UsernameService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> deleteUsername(String username) async {
    await _db.collection('usernames').doc(username).delete();
  }

  Future<void> saveUsername(String username) async {
    await _db.collection('usernames').doc(username).set({"username": username});
  }

  Future<bool> usernameIsUnique(String username) async {
    DocumentSnapshot doc = await _db
        .collection('usernames')
        .doc(username).get();

    return !doc.exists;
  }
}