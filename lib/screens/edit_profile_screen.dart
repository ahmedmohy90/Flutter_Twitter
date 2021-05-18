import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_flutter_app/services/database_services.dart';
import 'package:twitter_flutter_app/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({Key key, this.user}) : super(key: key);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String name;
  String bio;
  File _coverImage;
  File _profileImage;
  String _imagePickerType;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  displayCoverImage() {
    if (_coverImage == null) {
      if (widget.user.coverImage.isNotEmpty) {
       return NetworkImage(widget.user.coverImage);
      }
    } else {
     return FileImage(_coverImage);
    }
  }
  displayProfileImage() {
    if (_profileImage == null) {
      if (widget.user.profilePicture.isEmpty) {
        return AssetImage('assets/placeholder.png');
      } else {
        return NetworkImage(widget.user.profilePicture);
      }
    } else {
      return FileImage(_profileImage);
    }
  }

  saveProfile() async {
    if(!_formKey.currentState.validate()){
      return;
    }
    _formKey.currentState.save();
    String profileImageUrl = '';
    String coverImageUrl = '';
    setState(() {
          _isLoading = true;
        });
    if(_profileImage == null){
      profileImageUrl = widget.user.profilePicture;
    }else{
      profileImageUrl = await StorageService.uploadProfilePicture(
        widget.user.profilePicture, _profileImage
      );
    }
    if(_coverImage == null){
      coverImageUrl = widget.user.coverImage;
    }else{
      coverImageUrl = await StorageService.uploadCoverPicture(
        widget.user.coverImage, _coverImage
      );
    }
    UserModel user = UserModel(
      id: widget.user.id,
      name: name,
      profilePicture: profileImageUrl,
      bio:bio,
      coverImage: coverImageUrl
    );
    DatabaseServices.updateUserData(user);
    Navigator.pop(context);
    setState(() {
          _isLoading = false;
        });
  }

  handelImageFromGallery() async {
    final imagePicker =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    try {
      if (imagePicker != null) {
        if (_imagePickerType == 'Profile') {
          setState(() {
            _profileImage = imagePicker;
          });
        } else if (_imagePickerType == 'Cover') {
          setState(() {
            _coverImage = imagePicker;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    name = widget.user.name;
    bio = widget.user.bio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: 
      _isLoading
      ? Center(child: CircularProgressIndicator(),)
      :ListView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          GestureDetector(
            onTap: () {
              _imagePickerType = 'Cover';
              handelImageFromGallery();
            },
            child: Stack(
              children: [
                Container(
                  height: size.height * .25,
                  decoration: BoxDecoration(
                    color: kTweeterColor,
                    image:
                        (_coverImage == null && widget.user.coverImage.isEmpty)
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: displayCoverImage(),
                              ),
                  ),
                ),
                Container(
                  height: size.height * .25,
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.camera_alt,
                          size: size.height * .08, color: Colors.white),
                      Text(
                        'Change Cover Photo',
                        style: TextStyle(
                            color: Colors.white, fontSize: size.height * .03),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0.0, -40.0, 0.0),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _imagePickerType = 'Profile';
                        handelImageFromGallery();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                              radius: size.height * .06,
                              backgroundImage: displayProfileImage()),
                          CircleAvatar(
                            radius: size.height * .06,
                            backgroundColor: Colors.black54,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: size.height * .04,
                                    color: Colors.white),
                                Text(
                                  'Change Cover Photo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.height * .01),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        saveProfile();
                      },
                      child: Container(
                        width: size.width * .15,
                        height: size.height * .03,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kTweeterColor,
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontSize: size.height * .02,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: kTweeterColor),
                        ),
                        validator: (value) {
                          if (value.trim().length < 2) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        initialValue: bio,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: TextStyle(color: kTweeterColor),
                        ),
                        onSaved: (value) {
                          bio = value;
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
