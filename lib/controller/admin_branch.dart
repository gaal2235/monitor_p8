
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitor_geral/model/branch_carajas.dart';
import '../global.dart';

import '../model/branch_carajas.dart';

///chamada responsavel por validar login e senha e possibilitar login
class AdminBranch {
  static Future<List<BranchCarajas?>?>? branchCarajas() async {
    String url = "$gUrl/rest/ADMIN/FILIAIS";
    var response = await http.get(Uri.parse(url));



    List<BranchCarajas?> branchCrj = BranchCarajas.toList(json.decode(response.body));


    return branchCrj;
  }
}
