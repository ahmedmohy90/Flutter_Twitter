import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String id;
  String name;
  String profilePicture;
  String email;
  String bio;
  String coverImage;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.bio,
    this.coverImage,
    this.profilePicture
  });

  factory UserModel.fromDoc(DocumentSnapshot doc){
    return UserModel(
      id: doc.id,
      name: doc.data()['name'],
      email: doc.data()['email'],
      bio: doc.data()['bio'],
      profilePicture: doc['profilePicture'],
      coverImage: doc['coverImage']
    );
  }
}