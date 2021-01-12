import 'package:flutter/material.dart';

class AppTextLogin extends StatelessWidget {
  String label;
  String hint;
  bool password;
  TextEditingController controller;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FocusNode focusNode;
  Function next;

  AppTextLogin(
    this.label,
    this.hint, {
    this.password,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //onEditingComplete: next,
      controller: controller,
      validator: validator,
      style: TextStyle(fontSize: 20, color: Colors.grey),

      decoration: InputDecoration(
        hintText: hint,
        icon: Icon(
          Icons.person,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
