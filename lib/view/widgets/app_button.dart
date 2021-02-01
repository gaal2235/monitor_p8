import 'package:flutter/material.dart';
import 'package:monitor_geral/global.dart';

class AppButton extends StatelessWidget {
  String text;
  Function onPressed;

  bool showProgress;

  AppButton(this.text, {this.onPressed, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(

        alignment: Alignment.center,
        width: 500,
        height: 50,
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(30.0) //                 <--- border radius here
              ),
          gradient:  LinearGradient(
            colors: [colorApp, colorApp.shade900],
            begin: FractionalOffset.centerLeft,
            end: FractionalOffset.centerRight,
          ),
        ),
        child: ButtonTheme(
          shape:  RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(30.0),
          ),
          minWidth: 500.0,
          height: 500.0,
          child: FlatButton(
            child: showProgress
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(text,
                    style: TextStyle(color: Colors.white, fontSize: 22)),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
