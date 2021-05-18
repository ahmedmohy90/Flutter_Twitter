import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:twitter_flutter_app/screens/welcom_screen.dart';
import 'package:twitter_flutter_app/services/auth_services.dart';
import 'package:twitter_flutter_app/services/database_services.dart';
import 'package:twitter_flutter_app/services/storage_service.dart';
import 'package:twitter_flutter_app/widgets/tweet_widget.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const ProfileScreen({Key key, this.currentUserId, this.visitedUserId})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _followerCount = 0;
  int _followingCount = 0;
  int _profileSegmentedValue = 0;
  var isFollowing = false;
  List<Tweet> _allTweets = [];
  List<Tweet> _mediaTweet=[];
    UserModel userModel = UserModel();

  getAllTweets()async{
    List<Tweet> userTweets=  await DatabaseServices.getUserTweets(widget.visitedUserId);
    print(widget.visitedUserId);
    if(mounted)
    setState(() {
          _allTweets = userTweets;
          _mediaTweet = _allTweets.where((tweet)=>tweet.image.isNotEmpty).toList();
        });
  }

  Map<int, Widget> _profileTabs = <int, Widget>{
    0: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Tweet',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
    1: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Media',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
    2: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Likes',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
  };

  Widget buildProfileWidget(UserModel author) {
    switch (_profileSegmentedValue) {
      case 0:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _allTweets.length,
          itemBuilder: (context, i){
            return TweetWidget(
              currentUserId: widget.currentUserId,
              userModel:author,
              tweet:_allTweets[i]
            );
          },
        );
        break;
      case 1:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _mediaTweet.length,
          itemBuilder: (context, i){
            return TweetWidget(
              currentUserId: widget.currentUserId,
              userModel:author,
              tweet:_mediaTweet[i]
            );
          },
        );
        break;
      case 2:
        return Center(
          child: Text(
            'Likes',
            style: TextStyle(fontSize: 25),
          ),
        );
        break;
      default:
        return Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(fontSize: 25),
          ),
        );
        break;
    }
  }

  getFollowersCount() async {
    int followerCount =
        await DatabaseServices.followersNum(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followerCount = followerCount;
      });
    }
  }

  getFollowingCount() async {
    int followingCount =
        await DatabaseServices.followingNum(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  followOrUnfollow() {
    if (isFollowing) {
      unfollowUser();
    } else {
      followUser();
    }
  }

  unfollowUser() {
    DatabaseServices.unfollowUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      isFollowing = false;
      if(_followerCount>=1)
      _followerCount--;
    });
  }

  followUser() {
    DatabaseServices.followUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      isFollowing = true;
      _followerCount++;
    });
  }

  setupIsFollowing() async {
    bool isFollowingThisUser = await DatabaseServices.isFollowingUser(
        widget.currentUserId, widget.visitedUserId);
   if(mounted)
    setState(() {
      isFollowing = isFollowingThisUser;
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getFollowersCount();
    getFollowingCount();
    setupIsFollowing();
    getAllTweets();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder(
        future: usersRef.doc(widget.visitedUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kTweeterColor),
              ),
            );
          }
         userModel = UserModel.fromDoc(snapshot.data);
          return ListView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              Container(
                height: size.height * .25,
                decoration: BoxDecoration(
                  color: kTweeterColor,
                  image: userModel.coverImage.isEmpty
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(userModel.coverImage),
                        ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox.shrink(),
                      (widget.currentUserId == widget.visitedUserId)
                          ? Stack(
                              children: [
                                Container(
                                  height: size.height * .03,
                                  width: size.height * .03,
                                  color: Colors.black54,
                                ),
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                    size: size.height * .03,
                                  ),
                                  itemBuilder: (_) {
                                    return <PopupMenuItem<String>>[
                                      PopupMenuItem(
                                        value: 'logOut',
                                        child: Text('Logout'),
                                      ),
                                    ];
                                  },
                                  onSelected: (selectedItem) {
                                    if(selectedItem == 'logOut'){
                                      AuthServices.logout();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:(context)=>WelcomeScreen(),
                                        )
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0.0, -40, 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: size.height * .07,
                            backgroundImage: userModel.profilePicture.isEmpty
                                ? AssetImage('assets/placeholder.png')
                                : NetworkImage(userModel.profilePicture),
                          ),
                          (widget.currentUserId == widget.visitedUserId)
                              ? GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          user: userModel,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: size.width * .15,
                                    height: size.height * .03,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: kTweeterColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                            fontSize: size.height * .02,
                                            color: kTweeterColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    followOrUnfollow();
                                  },
                                  child: Container(
                                    width: size.width * .22,
                                    height: size.height * .032,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: isFollowing
                                          ? Colors.white
                                          : kTweeterColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: kTweeterColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isFollowing ? 'following' : 'follow',
                                        style: TextStyle(
                                            fontSize: size.height * .02,
                                            color: isFollowing
                                                ? kTweeterColor
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                      SizedBox(
                        height: size.height * .01,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(userModel.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * .025)),
                      ),
                      SizedBox(
                        height: size.height * .01,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(userModel.bio,
                            style: TextStyle(fontSize: size.height * .0175)),
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('$_followingCount Following',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                    fontSize: size.height * .0175)),
                          ),
                          SizedBox(width: size.width * .02),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Text('$_followerCount Followers',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                    fontSize: size.height * .0175)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),
                      Container(
                        width: size.width,
                        child: CupertinoSlidingSegmentedControl(
                          groupValue: _profileSegmentedValue,
                          thumbColor: kTweeterColor,
                          backgroundColor: Colors.blueGrey,
                          children: _profileTabs,
                          onValueChanged: (i) {
                            setState(() {
                              _profileSegmentedValue = i;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              buildProfileWidget(userModel)
            ],
          );
        },
      ),
    );
  }
}
