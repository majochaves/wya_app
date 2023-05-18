import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:wya_final/src/models/location.dart';

class LocationManager{
  LocationManager();


  Future<Location?> getLocationById(String locationId) async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('locations').doc(locationId).get();
    return Location.fromSnap(snap);
  }

  Future<void> createLocation(Location location) async{
    await FirebaseFirestore.instance.collection('locations').doc(location.locationId).set(location.toJson());
  }
}