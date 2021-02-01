import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';


///chamada responsavel realizar coleta portaria
class Concierge {
  static Future<dynamic> postConcierge() async {
    var url = 'http://172.40.1.7:7903/rest/AUDITORIAS/PORTARIA';
    Map date = {
      "canal": "AUDITOR",
      "romaneio": gfe,
      "placa": "${plate.replaceAll("-", "")}",
      "filialorigem": "0105",
      "filialdestino": "${dropdownValue.substring(0, 4)}",
      "chavenfe": "$nfCode",
      "idUsr": user.userCode
    };

    var body = json.encode(date);

    var response = await http.post(url, body: body);

    return json.decode(response.body);
  }
}
