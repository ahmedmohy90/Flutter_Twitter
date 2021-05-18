import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String id;
  String fromUserId;
  Timestamp timestamp;
  bool follow;

  Activity({this.id, this.fromUserId, this.timestamp, this.follow});

  factory Activity.fromDoc(DocumentSnapshot doc){
    return Activity(
      id: doc.id,
      fromUserId: doc.data()['fromUserId'],
      timestamp: doc.data()['timestamp'],
      follow: doc.data()['follow']
    );
  }
}
