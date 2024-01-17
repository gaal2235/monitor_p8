import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';

///chamada responsavel realizar coleta portaria
class Concierge {
  static Future<dynamic> postConcierge({String ori = "0105"}) async {
    String url = '$gUrl/rest/AUDITORIAS/PORTARIA';
    Map date = {
      "canal": "AUDITOR",
      "romaneio": gfe,
      "placa": "${plate.replaceAll("-", "")}",
      "filialorigem": "$ori",
      "filialdestino": "${dropdownValue.substring(0, 4)}",
      "chavenfe": "$nfCode",
      "idUsr": user?.userCode
    };

    var body = json.encode(date);

    var response = await http.post(Uri.parse(url), body: body);

    return json.decode(response.body);
  }
}
