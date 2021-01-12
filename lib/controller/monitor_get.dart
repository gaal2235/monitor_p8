import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/model/monitor.dart';
///chamada responsavel buscar coletas p8
class MonitorGet {
  static Future<List<Monitor>> getMonitor(
      {String dateInit = "",
      String dateEnd = "",
      String gfe = "",
      String plate = "",
      String branchCrjDestiny = ""}) async {
    var url =
        'http://172.40.1.7:7903/rest/AUDITORIAS/MONITOR?DATADE=$dateInit&DATAATE=$dateEnd&FILIALDESTINO=$branchCrjDestiny&ROMANEIO=$gfe&PLACAVEICULO=$plate';

    var response = await http.get(url);
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
