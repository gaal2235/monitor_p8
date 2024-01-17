
import 'package:flutter/material.dart';
import '../../global.dart';

Future<DateTime?>? getDate(context,dateText) {
  return showDatePicker(
    context: context,

    initialDate: dateText,
    firstDate: DateTime(2018),
    lastDate: DateTime(2080),


    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          primarySwatch: colorApp,
        ),
        child: child??Container(),
      );
    },
  );
}