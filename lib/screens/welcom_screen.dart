import 'package:flutter/material.dart';
import '../widgets/rounded_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: size.width,
                  ),
                  Image.asset(
                    'assets/logo.png',
                    width: size.width * .4,
                    height: size.height * .23,
                  ),
                  Text(
                    'See what\'s happening in the world right now',
                    style: TextStyle(
                        fontSize: size.height * .02,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  RoundedButton(btnText: 'LOG IN', btnOnPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen() ));
                  },),
                  SizedBox(
                    height: size.height*.03,
                  ),
                  RoundedButton(btnText: 'Create account', btnOnPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen() ));

                  },),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
