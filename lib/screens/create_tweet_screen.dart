import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:twitter_flutter_app/services/database_services.dart';
import 'package:twitter_flutter_app/services/storage_service.dart';
import 'package:twitter_flutter_app/widgets/rounded_button.dart';
class CreateTweetScreen extends StatefulWidget {
  final String currentId;

  const CreateTweetScreen({Key key, this.currentId}) : super(key: key);

  @override
  _CreateTweetScreenState createState() => _CreateTweetScreenState();
}

class _CreateTweetScreenState extends State<CreateTweetScreen> {
  String _tweetText;
  File _pickedImage;
  var _isLoading = false;

  uploadTweet() async{
    setState(() {
          _isLoading = true;
        });
     if(_tweetText != null && _tweetText != ''){
       String image;
       if(_pickedImage  == null){
         image = '';
       }else{
         image = await StorageService.uploadTweet(_pickedImage);
       }
        Tweet tweet = Tweet(
          txt: _tweetText,
          image: image,
          authodId: widget.currentId,
          likes: 0,
          retweets: 0,
          timestamp: Timestamp.fromDate(DateTime.now()),
        );
        DatabaseServices.createTweet(tweet);
        Navigator.pop(context);
     }   
    setState(() {
          _isLoading = false;
        });
  }
  handelImageFromGallery()async{
    try{

    }catch(e){
      print(e);
    }
    File _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(_image != null){
      setState(() {
                    _pickedImage = _image;

            });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kTweeterColor,
        title: Text('Tweet', style: TextStyle(color: Colors.white, fontSize: 20),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20,),
            TextField(
              maxLength: 280,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Enter Your Tweet'
              ),
              onChanged: (value){
                _tweetText = value;
              },
            ),
            SizedBox(height: 10,),
            _pickedImage == null
            ? SizedBox()
            :Container(
              height: 200,
              decoration: BoxDecoration(
                color: kTweeterColor,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(_pickedImage),
                ),
              ),
            )
            ,
            SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                handelImageFromGallery();
              },
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: kTweeterColor,
                ),
                ),
                child: Icon(Icons.camera_alt, color: kTweeterColor,size: 50,),  
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RoundedButton(
              btnText: 'Tweet',
              btnOnPressed: (){
                uploadTweet();
              },
            ),
            SizedBox(height: 20,),
            _isLoading
            ?CircularProgressIndicator()
            :SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}