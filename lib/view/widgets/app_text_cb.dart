import 'package:flutter/material.dart';

class AppTextCB extends StatelessWidget {
  String label;
  String hint;
  bool password;
  TextEditingController controller;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FocusNode focusNode;

  AppTextCB(
    this.label,
    this.hint, {
    this.password,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: password = true,
      validator: validator,
      textInputAction: textInputAction,
      style: TextStyle(fontSize: 25, color: Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontSize: 25,
          color: Colors.grey,
        ),
      ),
    );
  }
}
