import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:twitter_flutter_app/services/database_services.dart';
import 'package:twitter_flutter_app/widgets/tweet_widget.dart';

import 'create_tweet_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentId;

  const HomeScreen({Key key, this.currentId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _followingTweets = [];
  var _isLoading = false;

  buildTweets(Tweet tweet, UserModel author) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TweetWidget(
          tweet: tweet, userModel: author, currentUserId: widget.currentId),
    );
  }

  showFollowingTweets(String currentUserId) {
    List<Widget> followingTweets = [];
    for (Tweet tweet in _followingTweets) {
      followingTweets.add(FutureBuilder(
        future: usersRef.doc(tweet.authodId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel author = UserModel.fromDoc(snapshot.data);
            return buildTweets(tweet, author);
          } else {
            return SizedBox.shrink();
          }
        },
      ));
    }
    return followingTweets;
  }

  setupUpdateFollowingTweets() async {
    setState(() {
      _isLoading = true;
    });
    List followingTweets =
        await DatabaseServices.getHomeTweets(widget.currentId);
    setState(() {
      _followingTweets = followingTweets;
      _isLoading = false;
    });
  }
  @override
    void didChangeDependencies() {
      setupUpdateFollowingTweets();
      super.didChangeDependencies();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: .5,
          backgroundColor: Colors.white,
          leading: Container(
            height: 40,
            child: Image.asset('assets/logo.png'),
          ),
          title: Text(
            'Home',
            style: TextStyle(color: kTweeterColor),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateTweetScreen(
                          currentId: widget.currentId,
                        )));
          },
          backgroundColor: Colors.white,
          child: Image.asset(
            'assets/tweet2.png',
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => setupUpdateFollowingTweets(),
          child: ListView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              _isLoading ? LinearProgressIndicator() : SizedBox.shrink(),
              SizedBox(
                height: 10,
              ),
              Column(
                
                children: 
                                  _followingTweets.isEmpty && _isLoading == false

               ? [
                  SizedBox(height: 5,),
                       Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'There is no Tweets!',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                ]
                :                       showFollowingTweets(widget.currentId),

              )
            ],
          ),
        ));
  }
}
