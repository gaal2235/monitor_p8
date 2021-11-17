class BranchCarajas {
  String code;
  String initials;
  String cidadeEmpresa;

  BranchCarajas(
      {this.code,
        this.initials,
        this.cidadeEmpresa,
      });

  BranchCarajas.fromJson(Map<String, dynamic> json) {
    code = json['codigo'];
    initials = json['sigla'];
    cidadeEmpresa = json['cidadeEmpresa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['codigo'] = this.code;
    data['sigla'] = this.initials;
    data['cidadeEmpresa'] = this.cidadeEmpresa;
    return data;
  }
}
