import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wya_final/models/location.dart';
import 'package:wya_final/providers/chat_provider.dart';
import 'package:wya_final/providers/event_provider.dart';
import 'package:wya_final/providers/notification_provider.dart';
import 'package:wya_final/providers/user_provider.dart';
import 'package:wya_final/utils/location_provider.dart';
import 'package:wya_final/models/user_data.dart';
import 'models/chat_info.dart';
import 'models/notification.dart' as model;
import 'package:wya_final/models/chat.dart' as model;
import 'package:wya_final/models/message.dart' as model;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'models/event.dart';
import 'models/group.dart';
import 'firebase_options.dart';                       // new

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  final LocationProvider _locationProvider = LocationProvider();
  Future<LocationProvider> get location async {
    await _locationProvider.getCurrentLocation();
    return _locationProvider;
  }

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