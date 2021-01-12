import 'package:flutter/material.dart';

class AppTextSenha extends StatelessWidget {
  String label;
  String hint;
  bool password;
  TextEditingController controller;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FocusNode focusNode;

  AppTextSenha(
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
      style: TextStyle(fontSize: 20, color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        icon: Icon(
          Icons.lock,
          size: 40,
          color: Colors.grey,
        ),
        labelStyle: TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
      ),
    );
  }
}
