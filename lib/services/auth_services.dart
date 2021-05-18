import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices{
  
  static final _auth = FirebaseAuth.instance;
  static final _fireStore = FirebaseFirestore.instance;

  static Future<void> signup(String name ,String email, String password) async{
    try{
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User signedInUser = authResult.user;

      if(signedInUser != null){
        _fireStore.collection('users').doc(signedInUser.uid).set(
          {
            'name':name,
            'email':email,
            'profilePicture':'',
            'coverImage':'',
            'bio':''
          }
        );
      }

    }catch(e){
      print(e);
    }
  }
   static Future<void> login(String email, String password) async{
    try{
       _auth.signInWithEmailAndPassword(email: email, password: password);
    }catch(e){
      print(e);
    }
  }

  static void logout(){
    try{
      _auth.signOut();
    }catch(e){
      print(e);
      throw e;
    }
    
  }
}