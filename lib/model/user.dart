import 'package:monitor_geral/model/salesman_code.dart';

import 'operator_wms.dart';

class User {
  String? userCode;
  String? user;
  String? name;
  String? department;
  String? office;
  String? email;
  String? token;
  List<OperatorWMS>? operatorWms;
  List<SalesmanCode>? salesmanCode;

  User(
      {this.userCode,
      this.user,
      this.name,
      this.department,
      this.office,
      this.email,
      this.token,
      this.operatorWms,
      this.salesmanCode});

  User.fromJson(Map<String, dynamic> json) {
    userCode = json['codUser'];
    user = json['user'];
    name = json['nome'];
    department = json['depart'];
    office = json['cargo'];
    email = json['email'];
    token = json['token'];
    if (json['operadorWMS'] != null) {
      operatorWms =  [];
      json['operadorWMS'].forEach((v) {
        operatorWms?.add( OperatorWMS.fromJson(v));
      });
    }
    if (json['codVend'] != null) {
      salesmanCode =  [];
      json['codVend'].forEach((v) {
        salesmanCode?.add( SalesmanCode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['codUser'] = this.userCode;
    data['user'] = this.user;
    data['nome'] = this.name;
    data['depart'] = this.department;
    data['cargo'] = this.office;
    data['email'] = this.email;
    data['token'] = this.token;
    if (this.operatorWms != null) {
      data['operadorWMS'] = this.operatorWms?.map((v) => v.toJson()).toList();
    }
    if (this.salesmanCode != null) {
      data['codVend'] = this.salesmanCode?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}




