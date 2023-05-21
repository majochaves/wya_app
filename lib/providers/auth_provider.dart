import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../firebase_options.dart';

class Auth extends ChangeNotifier{
  ///Constructor
  Auth(){
    init();
  }

  ///Provider values
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  ///Listens to changes in user state and notifies listeners
  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}