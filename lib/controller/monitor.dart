import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';

///chamada responsavel buscar coletas p8
class MonitorManagement {
  static Future<List<Monitor>> getMonitor(
      {String received = "",
      String checked = "",
      String addressed = "",
      String concierge = "",
      String dateInit = "",
      String dateEnd = "",
      String gfe = "",
      String plate = "",
      bool noBranch = false}) async {
    String url = '$gUrl/rest/AUDITORIAS/MONITOR?'
        'DATADE=$dateInit&'
        'DATAATE=$dateEnd&FILIALDESTINO=${noBranch ? "" : dropdownValue.substring(0, 4)}&'
        'RECEBIDO=$received&'
        'CONFERIDO=$checked&ENDERECADO=$addressed&PORTARIA=$concierge&'
        'ROMANEIO=$gfe&PLACAVEICULO=$plate';

    var response = await http.get(Uri.parse(url));
    String json = response.body;

    //var colet  = Colet.fromJson(convert.json.decode(response.body));

    List list = convert.json.decode(json);
    final monitor = List<Monitor>();
    for (Map map in list) {
      Monitor m = Monitor.fromJson(map);

      monitor.add(m);
    }

    return monitor;
  }
}
