import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
class RoundedButton extends StatelessWidget {
  final Function btnOnPressed;
  final btnText;

  RoundedButton({this.btnText, this.btnOnPressed});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      elevation: 5,
      color: kTweeterColor,
      borderRadius: BorderRadius.circular(20),
      child: MaterialButton(
        minWidth: size.width*.45,
        height: size.height*.07,
        onPressed: btnOnPressed,
        child: Text(btnText, style: TextStyle(color: Colors.white, fontSize: 20),),
      ),
    );
  }
}