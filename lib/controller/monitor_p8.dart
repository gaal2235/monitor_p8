import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';


///chamada responsavel buscar coletas p8 filtradas
class MonitorConciergeP8 {
  static Future<List<Monitor>> getMonitorP8(
      {String gfe = "", String plate = ""}) async {
    var url =
        'http://172.40.1.7:7903/rest/AUDITORIAS/MONITOR?P8=S&FILIALDESTINO='
        '${dropdownValue.toString().substring(0, 4)}&ROMANEIO=$gfe&'
        'PLACAVEICULO=$plate';

    var response = await http.get(url);

    String json = response.body;

    List list = convert.json.decode(json);
    final monitorP8 = List<Monitor>();
    for (Map map in list) {
      Monitor m = Monitor.fromJson(map);

      monitorP8.add(m);
    }

    return monitorP8;
  }
}
