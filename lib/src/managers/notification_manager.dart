import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/notification.dart' as model;


class NotificationManager{
  NotificationManager();

  Future<void> addNotification(model.Notification notification) async {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.notificationId)
        .set(notification.toJson());
  }

  Future<void> setReadNotifications(String uid) async{
    QuerySnapshot nots = await FirebaseFirestore.instance
        .collection('notifications').where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    for(final not in nots.docs){
      await FirebaseFirestore.instance.collection('notifications').doc((not.data() as Map<String, dynamic>)['notificationId']).update({'isRead' : true});
    }
  }
}