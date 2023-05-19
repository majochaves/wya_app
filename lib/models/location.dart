import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String locationId;
  final String uid;
  final String? formattedAddress;
  final String? url;
  final double latitude;
  final double longitude;

  const Location( {
    required this.locationId,
    required this.uid,
    required this.formattedAddress,
    required this.url,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    "locationId" : locationId,
    "uid": uid,
    "formattedAddress": formattedAddress,
    "url": url,
    "latitude": latitude,
    "longitude" : longitude,
  };

  static Location fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Location(
      locationId: snapshot['locationId'],
      uid: snapshot['uid'],
      formattedAddress: snapshot['formattedAddress'],
      url: snapshot['url'],
      latitude: snapshot['latitude'],
      longitude: snapshot['longitude'],
    );
  }

  static Location emptyLocation(){
    return const Location(
      locationId: '',
      uid: '',
      formattedAddress: '',
      url: '',
      latitude: 23,
      longitude: 23,
    );
  }
}