import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/services/auth_services.dart';
import '../widgets/rounded_button.dart';
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _email, _password, _name;
  var _isLoading =false;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  Future<void> _signup(BuildContext context) async{
    if(!_form.currentState.validate()){
      return;
    }
    _form.currentState.save();
    try{
      setState(() {
              _isLoading = true;
            });
      final response = await AuthServices.signup(_name,_email, _password);
      Navigator.pop(context);
    }catch(e){
      print(e);
    }
    setState(() {
          _isLoading = false;
        });
  }

  @override
  Widget build(BuildContext context) {
        final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kTweeterColor
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Image.asset('assets/logo.png', width: 40,height: 40,)
      ),
      backgroundColor: Colors.white,
      body: 
      _isLoading
      ? Center(child: CircularProgressIndicator(),)
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _form,
            child: Column(
              children: [
                SizedBox(height: size.height*.02,),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Align(
                
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create your account', 
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),)),
                 ),
                  SizedBox(
                  height: size.height * .1,
                ),
                TextFormField(
                  validator: (value){
                    if(value == null || value == ''){
                      return 'please enter your name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Name',
                  ),
                 onChanged: (value){
                   _name = value;
                 }, 
                ),
                SizedBox(height: size.height*.03,),
                 
                TextFormField(
                  validator: (value){
                    if(value == null || value == ''){
                      return 'please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                 onChanged: (value){
                   _email = value;
                 }, 
                ),
                SizedBox(height: size.height*.03,),
                 TextFormField(
                   validator: (value){
                    if(value.length<=5){
                      return 'please enter password bigger than 5';
                    }
                    return null;
                  },
                   obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                 onChanged: (value){
                   _password = value;
                 }, 
                ),
                SizedBox(
                  height: size.height*.15,
                ),
                RoundedButton(btnText: 'Signup',btnOnPressed: (){
                  _signup(context);
                },),
              ],
            ),
          ),
        ),
      ),
    );
  }
}