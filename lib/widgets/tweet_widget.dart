import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/services/database_services.dart';

class TweetWidget extends StatefulWidget {
  final Tweet tweet;
  final UserModel userModel;
  final String currentUserId;

  TweetWidget({this.tweet, this.userModel, this.currentUserId});

  @override
  _TweetWidgetState createState() => _TweetWidgetState();
}

class _TweetWidgetState extends State<TweetWidget> {
  int _likesCount= 0;
  var _isLiked = false;


  initTweetLikes() async{
    bool isLiked = await DatabaseServices.isLikedTweet(widget.currentUserId, widget.tweet);
    setState(() {
          _isLiked = isLiked; 
        });
  }

  likeTweet(){
    if(_isLiked){
      DatabaseServices.unlikeTweet(widget.currentUserId, widget.tweet);
      setState(() {
              _isLiked = false;
              
              _likesCount--;
            });
    }else{
      DatabaseServices.likeTweet(widget.currentUserId, widget.tweet);
      setState(() {
              _isLiked = true;
              _likesCount++;
            });
    }
  }
 
 @override
   void didChangeDependencies() {
     _likesCount = widget.tweet.likes;
     initTweetLikes();
     super.didChangeDependencies();
   }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.userModel.profilePicture.isEmpty
                    ? AssetImage('assets/placeholder.png')
                    : NetworkImage(widget.userModel.profilePicture),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.userModel.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(widget.tweet.txt),
          SizedBox(height: 20),
          widget.tweet.image.isEmpty
              ? SizedBox.shrink()
              : Container(
                  height: 250,
                  decoration: BoxDecoration(
                      color: kTweeterColor,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: NetworkImage(widget.tweet.image))),
                ),
          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            likeTweet();
                          }, 
                          
                          icon: Icon(
                            _isLiked
                            ?Icons.favorite
                            :Icons.favorite_border
                            ),
                            color: _isLiked ?kTweeterColor :Colors.black
                            ),
                      Text('${_likesCount.toString()} Likes'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.repeat)),
                      Text('${widget.tweet.retweets.toString()} Retweets'),
                    ],
                  )
                ],
              ),
              Text(widget.tweet.timestamp.toDate().toString().substring(0,11), style: TextStyle(color: Colors.grey),)
            ],
          ),
          SizedBox(height: 10,),
          Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}
