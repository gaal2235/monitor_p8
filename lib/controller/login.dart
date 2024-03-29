import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/user.dart';

///chamada responsavel por validar login e senha e possibilitar login
class Login {
  static Future<User?>? login(String usr, String pwd) async {
    String url = '$gUrl/rest/AUTHUSER?USR=$usr&PWD=$pwd';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body != []) {
        user = User.fromJson(json.decode(response.body));

        return user;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
