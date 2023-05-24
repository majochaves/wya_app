import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '/models/location.dart';

class EventLocationService{
  EventLocationService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<Location?> getLocationById(String locationId) async{
    DocumentSnapshot snap = await _db.collection('locations').doc(locationId).get();
    return Location.fromSnap(snap);
  }

  Future<void> saveLocation(Location location) async{
    await _db.collection('locations').doc(location.locationId).set(location.toJson());
  }

  Future<void> deleteLocation(String locationId) async{
    await _db.collection('locations').doc(locationId).delete();
  }

  Future<void> deleteLocationsForUser(String uid) async{
    await _db
        .collection('locations')
        .where('uid', isEqualTo: uid)
        .get().then((value) => value.docs.forEach((element) {
      Location location = Location.fromSnap(element);
      deleteLocation(location.locationId);
    }));
  }
} 