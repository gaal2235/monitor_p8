class BranchCarajas {
  String code;
  String initials;

  BranchCarajas(
      {this.code, this.initials,});

  BranchCarajas.fromJson(Map<String, dynamic> json) {
    code = json['codigo'];
    initials = json['sigla'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['codigo'] = this.code;
    data['sigla'] = this.initials;
    return data;
  }
}
