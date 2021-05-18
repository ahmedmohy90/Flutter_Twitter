import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:twitter_flutter_app/screens/profile_screen.dart';
import 'package:twitter_flutter_app/services/database_services.dart';

class SearchScreen extends StatefulWidget {
  final String currentUserId;

  const SearchScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot> _users;
  TextEditingController _searchController = TextEditingController();

  clearSearch() {
    _searchController.clear();
    setState(() {
      _users = null;
    });
  }

  buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.profilePicture.isEmpty
            ? AssetImage('assets/placeholder.png')
            : NetworkImage(user.profilePicture),
      ),
      title: Text(user.name),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => ProfileScreen(
                    currentUserId: widget.currentUserId,
                    visitedUserId: user.id,
                  )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: .5,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                hintText: 'Search Twiter...',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    clearSearch();
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                )),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _users = DatabaseServices.searchUsers(value);
                });
              }
            },
          ),
        ),
        body: _users == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 100,
                    ),
                    Text(
                      'Search Tweeter...',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
                    )
                  ],
                ),
              )
            : FutureBuilder<QuerySnapshot>(
                future: _users,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data.docs.length == 0) {
                    return Text('No Users Found!');
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (ctx, i) {
                      UserModel user = UserModel.fromDoc(snapshot.data.docs[i]);
                      return buildUserTile(user);
                    },
                  );
                },
              ));
  }
}
