import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/tweet.dart';
import 'package:uuid/uuid.dart';

class StorageService{
  static Future<String> uploadProfilePicture(String url, File imageFile)async{
    String uniquePhotoId = Uuid().v4();
    File image =  await compressImage(uniquePhotoId, imageFile);
    if(url.isNotEmpty){
      RegExp exp =  RegExp(r'userProfile_(.*).jpg');
      uniquePhotoId = exp.firstMatch(url)[1];
    }
    UploadTask uploadTask = storageRef.child('image/users/userProfile_$uniquePhotoId.jpg').putFile(
      image
    );
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(()=>null);
    String downloadUrl =await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  static Future<String> uploadCoverPicture(String url, File imageFile)async{
    String uniquePhotoId = Uuid().v4();
    File image =  await compressImage(uniquePhotoId, imageFile);
    if(url.isNotEmpty){
      RegExp exp =  RegExp(r'userCover_(.*).jpg');
      uniquePhotoId = exp.firstMatch(url)[1];
    }
    UploadTask uploadTask = storageRef.child('image/users/userCover_$uniquePhotoId.jpg').putFile(
      image
    );
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(()=>null);
    String downloadUrl =await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
   static Future<String> uploadTweet(File imageFile)async{
    String uniquePhotoId = Uuid().v4();
    File image =  await compressImage(uniquePhotoId, imageFile);
   
    UploadTask uploadTask = storageRef.child('image/tweets/tweet_$uniquePhotoId.jpg').putFile(
      image
    );
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(()=>null);
    String downloadUrl =await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<File> compressImage(String photoId, File imageFile)async{
    final tempDirection = await getTemporaryDirectory();
    final path = tempDirection.path;
    File compressedImage = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70
    );
    return compressedImage;
  }

}