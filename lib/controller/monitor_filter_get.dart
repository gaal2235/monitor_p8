import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';

///chamada responsavel buscar coletas p8 filtradas
class MonitorFilterGet {
  static Future<List<Monitor>> getMonitorFilter(
      {String received = "",
      String checked = "",
      String addressed = "",
      String concierge = "",
      String dateInit = "",
      String dateEnd = "",
      String gfe = "",
      String plate = ""}) async {
    var url = 'http://172.40.1.7:7903/rest/AUDITORIAS/MONITOR?DATADE=$dateInit&'
        'DATAATE=$dateEnd&FILIALDESTINO=$dropdownValue&RECEBIDO=$received&'
        'CONFERIDO=$checked&ENDERECADO=$addressed&PORTARIA=$concierge&'
        'ROMANEIO=$gfe&PLACAVEICULO=$plate';

    var response = await http.get(url);
    String json = response.body;

    //var colet  = Colet.fromJson(convert.json.decode(response.body));

    List list = convert.json.decode(json);
    final monitorFilter = List<Monitor>();
    for (Map map in list) {
      Monitor m = Monitor.fromJson(map);

      monitorFilter.add(m);
    }

    return monitorFilter;
  }
}