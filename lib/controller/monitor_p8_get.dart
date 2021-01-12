import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';
///chamada responsavel buscar coletas p8 geral
class ApiMonitorP8 {
  static Future<List<Monitor>> getApiMonitorP8() async {
    var url =
        'http://172.40.1.7:7903/rest/AUDITORIAS/MONITOR?P8=S&FILIALDESTINO=$dropdownValue';

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
