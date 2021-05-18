import 'package:cloud_firestore/cloud_firestore.dart';

class Tweet{
  String id;
  String authodId;
  String txt;
  String image;
  Timestamp timestamp;
  int likes;
  int retweets;

  Tweet({
    this.id,
    this.authodId,
    this.txt,
    this.image,
    this.timestamp,
    this.likes,
    this.retweets
  });

  factory Tweet.fromDoc(DocumentSnapshot doc){
    return Tweet(
      id:doc.id,
      authodId: doc['authodId'],
      txt: doc.data()['text'],
      image: doc.data()['image'],
      timestamp: doc.data()['timesstamp'],
      likes: doc.data()['likes'],
      retweets: doc.data()['retweets']
    );
  }
}