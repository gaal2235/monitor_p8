import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';

///chamada responsavel buscar coletas p8 filtradas
class MonitorConciergeP8 {
  static Future<List<Monitor?>?> getMonitorP8(
      {String dateInit = "",
      String dateEnd = "",
      String gfe = "",
      String plate = "",
      int off = 0,
      int limit = 100}) async {
    String url = '$gUrl/rest/AUDITORIAS/MONITOR?P8=S&FILIALDESTINO='
        '${dropdownValue.toString().substring(0, 4)}&ROMANEIO=$gfe&'
        'DATADE=$dateInit&'
        'DATAATE=$dateEnd&'
        'PLACAVEICULO=$plate';

    var response = await http.get(Uri.parse(url), headers: {
      "offset": "$off",
      if (limit != null) ...{"limit": "$limit"}
    });

    List<Monitor?>? monitorP8 = Monitor.toList(json.decode(response.body));
    return monitorP8;
  }
}
