import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:username_gen/username_gen.dart';
import 'package:wya_final/models/user_data.dart';

import '../firebase_options.dart';
import '../services/user_service.dart';
import '../services/username_service.dart';

class Auth extends ChangeNotifier {
  ///Firebase Auth Instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  ///Constructor
  Auth() {
    init();
  }

  ///Provider values
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  ///Services
  final userService = UserService();
  final usernameService = UsernameService();

  ///Listens to changes in user state and notifies listeners
  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    auth.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  ///Provider methods
  Future<String> loginUser(String email, String password) async {
    String res = 'success';
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        res = 'The email entered does not match any existing account';
      } else if (e.code == "wrong-password") {
        res = 'The password entered is not correct';
      } else {
        res = 'Unknown error.';
      }
    }
    return res;
  }

  Future<String> loginUserWithGoogle() async {
    String res = 'success';
    final googleUser = await GoogleSignIn(
            clientId:
                '536153952717-2d1ad23q7bcbhiq2khkr5umk5lthtgc5.apps.googleusercontent.com')
        .signIn();

    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
      if (auth.currentUser != null) {
        bool exists = await userService.userDataExists(auth.currentUser!.uid);
        if(!exists){
          bool uniqueUsername = false;
          String username = '';
          while(!uniqueUsername){
            username = generateRandomUsername();
            uniqueUsername = await usernameIsUnique(username);
          }
          await saveNewUserData(username);
        }
        try {
          await auth.currentUser?.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case "provider-already-linked":
              print("The provider has already been linked to the user.");
              break;
            case "invalid-credential":
              print("The provider's credential is not valid.");
              break;
            case "credential-already-in-use":
              print(
                  "The account corresponding to the credential already exists, "
                  "or is already linked to a Firebase User.");
              break;
            default:
              print("Unknown error.");
          }
        }
      }
    }else{
      res = 'Error: Could not sign in with Google account.';
    }
    return res;
  }

  Future<String> registerUser(
      String email, String username, String password) async {
    String res = 'success';
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else {
        res = 'Error: ${e.message}';
      }
    } catch (e) {
      print(e);
    }
    if (res == 'success') {
      saveNewUserData(username);
    }
    return res;
  }

  Future<void> saveNewUserData(String username) async{
    User? user = auth.currentUser;
    await usernameService.saveUsername(username);
    var newUserData = UserData(
        name: '',
        email: user!.email!,
        photoUrl:
        'https://firebasestorage.googleapis.com/v0/b/wya-app-d1efb.appspot.com/o/profilePics%2FnewUserProfilePicture.jpg?alt=media&token=5e39f00e-d84e-43d2-80df-05e1de6d114b',
        uid: user!.uid,
        username: username,
        events: [],
        groups: [],
        allowAdd: true,
        maxMatchDistance: 100,
        notifications: [],
        chats: [],
        friends: [],
        requests: [],
        pendingRequests: []);
    await userService.saveUserData(newUserData);
  }

  /*Aux methods*/
  Future<bool> usernameIsUnique(String val) async {
    return usernameService.usernameIsUnique(val);
  }

  String generateRandomUsername(){
    return UsernameGen.generateWith(data: UsernameGenData(names: ['user'], adjectives: ['wya']), seperator: '_');
  }
}
