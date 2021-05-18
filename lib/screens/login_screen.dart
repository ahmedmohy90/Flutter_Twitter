import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/services/auth_services.dart';
import 'package:twitter_flutter_app/widgets/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password;
  var _isLoading = false;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  Future<void> _login(BuildContext context) async{
    try{
      setState(() {
              _isLoading = true;
            });
            await AuthServices.login(_email, _password);
            Navigator.pop(context);
    }catch(e){
      print('something went wrong');
      showDialog(
        
         barrierDismissible: false,
        context: context,
        builder: (ctx) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              margin: EdgeInsets.all(32),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor,
                      ]),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'An error occur',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.message,                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                    height: 1,
                  ),
                  FlatButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                     Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      );
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _form,
          child: Column(
            children: [
              SizedBox(
                height: size.height * .02,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Log in to Twitter', 
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold),)),
                SizedBox(
                height: size.height * .02,
              ),    
              TextFormField(
                validator: (value) {
                  if (value == null || value == '') {
                    return 'please enter your email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                ),
                onChanged: (value) {
                  _email = value;
                },
              ),
              SizedBox(
                height: size.height * .03,
              ),
              TextFormField(
                validator: (value) {
                  if (value.length <= 5) {
                    return 'please enter password bigger than 5';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                ),
                onChanged: (value) {
                  _password = value;
                },
              ),
              SizedBox(
                height: size.height * .15,
              ),
              RoundedButton(
                btnText: 'LOG IN',
                btnOnPressed: () {
                  _login(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
