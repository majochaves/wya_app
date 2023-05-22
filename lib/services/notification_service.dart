import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/notification.dart' as model;

class NotificationService {
  NotificationService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<model.Notification>> getNotifications(String uid) {
      return _db
          .collection('notifications')
          .orderBy('created', descending: true)
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((document) => model.Notification.fromSnap(document))
              .toList());
  }

  Future<void> saveNotification(model.Notification notification) async{
    return await _db
        .collection('notifications')
        .doc(notification.notificationId)
        .set(notification.toJson());
  }

  Future<void> setReadNotifications(String uid) async {
    QuerySnapshot nots = await _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    for (final not in nots.docs) {
      await _db
          .collection('notifications')
          .doc((not.data() as Map<String, dynamic>)['notificationId'])
          .update({'isRead': true});
    }
  }
}
