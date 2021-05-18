import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/activity.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:twitter_flutter_app/models/user_model.dart';

class DatabaseServices {
  static Future<int> followersNum(String userId) async {
    QuerySnapshot followerSnapshot =
        await followerRef.doc(userId).collection('userFollowers').get();
    return followerSnapshot.docs.length;
  }

  static Future<int> followingNum(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('userFollowing').get();
    return followingSnapshot.docs.length;
  }

  static void updateUserData(UserModel user) {
    usersRef.doc(user.id).update({
      'name': user.name,
      'bio': user.bio,
      'profilePicture': user.profilePicture,
      'coverImage': user.coverImage
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) async {
    Future<QuerySnapshot> users = usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: name + 'z')
        .get();
    return users;
  }

  static void followUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(visitedUserId)
        .set({});

    followerRef
        .doc(visitedUserId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    addActivity(currentUserId, null, true, visitedUserId);    
  }

  static void unfollowUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followerRef
        .doc(visitedUserId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      String currentUserId, String visitedUserId) async {
    DocumentSnapshot followingDoc = await followerRef
        .doc(visitedUserId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    print('VistitedId is: $visitedUserId');
    return followingDoc.exists;
  }

  static void createTweet(Tweet tweet) {
    tweetsRef.doc(tweet.authodId).set({'tweetTime': tweet.timestamp});
    tweetsRef.doc(tweet.authodId).collection('userTweets').add({
      'authodId': tweet.authodId,
      'text': tweet.txt,
      'image': tweet.image,
      'timesstamp': tweet.timestamp,
      'likes': tweet.likes,
      'retweets': tweet.retweets,
    }).then((doc) async {
      QuerySnapshot followerSnapshot = await followerRef
          .doc(tweet.authodId)
          .collection('userFollowers')
          .get();
      for (var docSnapshot in followerSnapshot.docs) {
        feedRefs.doc(docSnapshot.id).collection('userFeed').doc(doc.id).set({
          'authodId': tweet.authodId,
          'text': tweet.txt,
          'image': tweet.image,
          'timesstamp': tweet.timestamp,
          'likes': tweet.likes,
          'retweets': tweet.retweets,
        });
      }
    });
  }

  static Future<List> getUserTweets(String userId) async {
    QuerySnapshot userTweetsSnapshots =
        await tweetsRef.doc(userId).collection('userTweets').get();
    List<Tweet> userTweets =
        userTweetsSnapshots.docs.map((doc) => Tweet.fromDoc(doc)).toList();
    return userTweets;
  }

  static Future<List> getHomeTweets(String userId) async {
    QuerySnapshot homeTweets =
        await feedRefs.doc(userId).collection('userFeed').get();

    List<Tweet> followingTweets = homeTweets.docs.map((doc) {
      return Tweet.fromDoc(doc);
    }).toList();
    return followingTweets;
  }
 
  static void likeTweet(String userId, Tweet tweet) {
       DocumentReference tweetDocProfile =
        tweetsRef.doc(tweet.authodId).collection('userTweets').doc(tweet.id);
    tweetDocProfile.get().then((doc) {
      int likes = doc.data()['likes'];
      tweetDocProfile.update({'likes': likes + 1});
    });

    DocumentReference tweetDocFeed =
        feedRefs.doc(userId).collection('userFeed').doc(tweet.id);
    tweetDocFeed.get().then((doc) {
      if (doc.exists) {
        int likes = doc.data()['likes'];
        tweetDocFeed.update({'likes': likes + 1});
      }
    });

    likeRefs.doc(tweet.id).collection('tweetLikes').doc(userId).set({});
    addActivity(userId, tweet, false, null);
}

  static void unlikeTweet(String userId, Tweet tweet) {
    DocumentReference tweetDocProfile =
        tweetsRef.doc(tweet.authodId).collection('userTweets').doc(tweet.id);
    tweetDocProfile.get().then((doc) {
      if (userId == null || tweet == null) {
        return;
      } else {
        int likes = doc.data()['likes'];
        tweetDocProfile.update({'likes': likes - 1});
      }
    });

    DocumentReference tweetDocFeed =
        tweetsRef.doc(userId).collection('userFeed').doc(tweet.id);
    tweetDocFeed.get().then((doc) {
      if (doc.exists) {
        int likes = doc['likes'];
        tweetDocFeed.update({'likes': likes - 1});
      }
    });
    likeRefs
        .doc(tweet.id)
        .collection('tweetLikes')
        .doc(userId)
        .get()
        .then((doc) {
      return doc.reference.delete();
    });
  }

  static Future<bool> isLikedTweet(String userId, Tweet tweet) async {
    DocumentSnapshot userDoc =
        await likeRefs.doc(tweet.id).collection('tweetLikes').doc(userId).get();
    return userDoc.exists;
  }
  static Future<List<Activity>> getActivities(String userId) async {
     QuerySnapshot userActivitySnapshot = await activityRef.doc(userId)
          .collection('userActivities').orderBy('timestamp', descending: true).get(); 
     List<Activity> activities = userActivitySnapshot.docs.map((activity){
       return Activity.fromDoc(activity);
     }).toList();
     return activities;     
  }
  static void addActivity(
    String currentId, Tweet tweet, bool follow, String followedUserId){
      if(follow){
        activityRef.doc(followedUserId).collection('userActivities').add({
          'fromUserId':currentId,
          'timestamp':Timestamp.fromDate(DateTime.now()),
          'follow':true
        });
      }else{
        activityRef.doc(tweet.authodId).collection('userActivities').add(
          {
            'fromUserId':currentId,
          'timestamp':Timestamp.fromDate(DateTime.now()),
          'follow':false,
          }
        );
      }
  }
}
