import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:monitor_geral/model/branch_carajas.dart';


///chamada responsavel por validar login e senha e possibilitar login
class AdminBranch {
  static Future<List<BranchCarajas>> branchCarajas() async {
    var url;

    url = "http://172.40.1.7:9198/rest/ADMIN/FILIAIS?APP=auditor";
    var response = await http.get(url);

    String json = response.body;



    List list = convert.json.decode(json);
    final branchCrj = List<BranchCarajas>();
    for (Map map in list) {
      BranchCarajas b = BranchCarajas.fromJson(map);

      branchCrj.add(b);
    }
  return branchCrj;
  }
}
