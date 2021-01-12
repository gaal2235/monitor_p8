import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monitor_geral/controller/login_get.dart';
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/view/monitoring.dart';
import 'package:monitor_geral/view/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class Company {
  dynamic res = 0;
  int id;
  String name;
  Company(this.id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, '0101 - MCZ'),
      Company(2, '0103 - ARA'),
      Company(3, '0104 - JPA'),
      Company(4, '0105 - CD'),
      Company(5, '0106 - CGE'),
      Company(6, '0107 - NAT'),
      Company(7, '0108 - CBD'),
      Company(8, '0109 - FOR'),
      Company(9, '0110 - JUA'),
      Company(10, '0201 - DV'),
    ];
  }
}

class _LoginPageState extends State<LoginPage> {
  bool selected = false;
  final _formKey = GlobalKey<FormState>();

  final _tUsr = TextEditingController();

  final _tPwd = TextEditingController();

  final _controller = ScrollController();

  final _focusPassword = FocusNode();

  final _loginFocus = FocusNode();

  Function next;

  bool _showProgress = false;
  void initState() {
    // TODO: implement initState
    super.initState();

    _loginprefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          controller: _controller,
          child: Stack(children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [colorApp, colorApp.shade900])),
            ),
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/P8.png',
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: MediaQuery.of(context).size.height * 0.560,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Card(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30),
                ),
                color: Colors.white,
                elevation: 9.0,
                margin: EdgeInsets.only(
                  right: 350.0,
                  left: 350.0,
                  bottom: 0,
                  top: MediaQuery.of(context).size.height * 0.57,
                ),
                child: Container(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            /*Center(child:Text("Selecione a filial:"), ),
                    DropdownButton(

                      value: _selectedCompany,
                      items: _dropdownMenuItems,
                      onChanged: onChangeDropdownItem,

                    ),*/
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Focus(
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: colorApp,
                                    cursorColor: colorApp),
                                child: TextFormField(
                                  controller: _tUsr,
                                  textInputAction: TextInputAction.next,
                                  validator: (s) => _validateLogin(s),
                                  focusNode: _loginFocus,
                                  onFieldSubmitted: (term) {
                                    _fieldFocusChange(
                                        context, _loginFocus, _focusPassword);
                                  },
                                  onTap: () {
                                    Timer(
                                        Duration(seconds: 1),
                                            () => _controller.jumpTo(_controller
                                            .position.maxScrollExtent));
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Digite o login',
                                    icon: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              onFocusChange: (login) {
                                Timer(
                                    Duration(seconds: 1),
                                        () => _controller.jumpTo(
                                        _controller.position.maxScrollExtent));
                              },
                            ),
                            SizedBox(height: 10),
                            Theme(
                              data: ThemeData(
                                  primaryColor: colorApp, cursorColor: colorApp),
                              child: TextFormField(
                                controller: _tPwd,
                                validator: _validatePassword,
                                focusNode: _focusPassword,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (value) {
                                  _focusPassword.unfocus();
                                  _onClickLogin();
                                },
                                onTap: () {
                                  Timer(
                                      Duration(seconds: 1),
                                          () => _controller.jumpTo(
                                          _controller.position.maxScrollExtent));
                                },
                                style:
                                TextStyle(fontSize: 16, color: Colors.grey),
                                decoration: InputDecoration(
                                  hintText: "Digite a senha",
                                  icon: Icon(
                                    Icons.lock,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height * 0.01,
                                ),
                              ],
                            ),
                            StreamBuilder<bool>(
                              initialData: false,
                              builder: (context, snapshot) {
                                return AppButton(
                                  "Login",
                                  onPressed: _onClickLogin,
                                  showProgress: _showProgress,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ])),
    );
  }
  ///quarda login do ultimo usuario logado
  _loginprefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tUsr.text = prefs.getString('login');
      _tPwd.text = prefs.getString('senha');
    });
  }
  void _onClickLogin() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    String usr = _tUsr.text;
    String pwd = _tPwd.text;



    setState(() {
      _showProgress = true;
    });


    user = await LoginGet.login(usr, pwd);

    if (user != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Monitoring()));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('login', _tUsr.text);
      prefs.setString('senha', _tPwd.text);

      // push(context, Home());


    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Column(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red.withOpacity(0.8),
                  size: 200,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text("Login e/ou Senha inválido(s)"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text(
                  "OK",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    //alert

    setState(() {
      _showProgress = false;
    });
  }
  ///valida login
  String _validateLogin(String text) {
    if (text.isEmpty) {
      return "Digite o login";
    }

    return null;
  }
  ///valida senha
  String _validatePassword(String text) {
    if (text.isEmpty) {
      return "Digite a senha";
    }
    if (text.length < 3) {
      return "A senha precisa ter pelo menos 3 números";
    }
    return null;
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
