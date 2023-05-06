import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String locationId;
  final String uid;
  final String? formattedAddress;
  final String? address;
  final String? url;
  final String? name;
  final double latitude;
  final double longitude;

  const Location( {
    required this.locationId,
    required this.uid,
    required this.formattedAddress,
    required this.address,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    "locationId" : locationId,
    "uid": uid,
    "formattedAddress": formattedAddress,
    "address" : address,
    "url": url,
    "latitude": latitude,
    "longitude" : longitude,
    "name" : name,
  };

  static Location fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Location(
      locationId: snapshot['locationId'],
      uid: snapshot['uid'],
      formattedAddress: snapshot['formattedAddress'],
      address: snapshot['address'],
      url: snapshot['url'],
      latitude: snapshot['latitude'],
      longitude: snapshot['longitude'],
      name: snapshot['name'],
    );
  }

  static Location emptyLocation(){
    return const Location(
      locationId: '',
      uid: '',
      formattedAddress: '',
      address: '',
      url: '',
      latitude: 23,
      longitude: 23,
      name: '',
    );
  }
}