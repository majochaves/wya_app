import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class ImageManager{
  ImageManager();

  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost, String uid) async {
    Reference ref =
    FirebaseStorage.instance.ref().child(childName).child(uid);

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}