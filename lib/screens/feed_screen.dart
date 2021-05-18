import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';

import 'create_tweet_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
class FeedScreen extends StatefulWidget {
  final String currentUserId;

  const FeedScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
    HomeScreen(
      currentId: widget.currentUserId,
    ),
    SearchScreen(
      currentUserId:widget.currentUserId,
    ),
    NotificationScreen(widget.currentUserId),
    ProfileScreen(
      currentUserId: widget.currentUserId,
      visitedUserId: widget.currentUserId,
    ),
  ].elementAt(_selectedIndex),
     
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index){
          setState(() {
                      _selectedIndex = index;
                    });
        },
        currentIndex: _selectedIndex,
        selectedItemColor: kTweeterColor,
        unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home,), title: Text('Home')),
        BottomNavigationBarItem(icon: Icon(Icons.search),title: Text('Search')),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), title: Text('Notification')),
        BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile')),
        
      ],  
      ),
    );
  }
}