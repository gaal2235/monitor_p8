import 'package:flutter/material.dart';

class AppButtonTrans extends StatelessWidget {
  String text;
  Function onPressed;

  bool showProgress;

  AppButtonTrans(this.text, {this.onPressed, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        width: 500,
        height: 50,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(30.0) //                 <--- border radius here
              ),
          gradient: new LinearGradient(
            colors: [Colors.orange, Colors.orange],
            begin: FractionalOffset.centerLeft,
            end: FractionalOffset.centerRight,
          ),
        ),
        child: FlatButton(
          child: showProgress
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(text, style: TextStyle(color: Colors.white, fontSize: 22)),
        ),
      ),
      onTap: onPressed,
    );
  }
}
