class User {
  String codUser;
  String user;
  String name;
  String department;
  String office;
  String email;
  String token;
  List<OperatorWMS> operatorWms;
  List<CodVend> codSalesman;

  User(
      {this.codUser,
      this.user,
      this.name,
      this.department,
      this.office,
      this.email,
      this.token,
      this.operatorWms,
      this.codSalesman});

  User.fromJson(Map<String, dynamic> json) {
    codUser = json['codUser'];
    user = json['user'];
    name = json['nome'];
    department = json['depart'];
    office = json['cargo'];
    email = json['email'];
    token = json['token'];
    if (json['operadorWMS'] != null) {
      operatorWms = new List<OperatorWMS>();
      json['operadorWMS'].forEach((v) {
        operatorWms.add(new OperatorWMS.fromJson(v));
      });
    }
    if (json['codVend'] != null) {
      codSalesman = new List<CodVend>();
      json['codVend'].forEach((v) {
        codSalesman.add(new CodVend.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codUser'] = this.codUser;
    data['user'] = this.user;
    data['nome'] = this.name;
    data['depart'] = this.department;
    data['cargo'] = this.office;
    data['email'] = this.email;
    data['token'] = this.token;
    if (this.operatorWms != null) {
      data['operadorWMS'] = this.operatorWms.map((v) => v.toJson()).toList();
    }
    if (this.codSalesman != null) {
      data['codVend'] = this.codSalesman.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OperatorWMS {
  String branchOperator;
  String branchOperatorName;
  String statusOperator;
  String codUsrOperator;

  OperatorWMS(
      {this.branchOperator,
      this.branchOperatorName,
      this.statusOperator,
      this.codUsrOperator});

  OperatorWMS.fromJson(Map<String, dynamic> json) {
    branchOperator = json['filialOperador'];
    branchOperatorName = json['siglaFilialOperador'];
    statusOperator = json['statusOperador'];
    codUsrOperator = json['codUsrOperador'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filialOperador'] = this.branchOperator;
    data['siglaFilialOperador'] = this.branchOperatorName;
    data['statusOperador'] = this.statusOperator;
    data['codUsrOperador'] = this.codUsrOperator;
    return data;
  }
}

class CodVend {
  String branchCrj;
  String uf;
  String branchCrjName;
  String companyName;
  String companyGroup;
  String companyAddress;
  String companyCity;
  String companyUf;
  String companyNeighborhood;
  String companyCep;
  String ip;
  dynamic porcPromotion;
  String codSalesman;
  String codOffice;
  String officeName;

  CodVend(
      {this.branchCrj,
      this.uf,
      this.branchCrjName,
      this.companyName,
      this.companyGroup,
      this.companyAddress,
      this.companyCity,
      this.companyUf,
      this.companyNeighborhood,
      this.companyCep,
      this.ip,
      this.porcPromotion,
      this.codSalesman,
      this.codOffice,
      this.officeName});

  CodVend.fromJson(Map<String, dynamic> json) {
    branchCrj = json['filial'];
    uf = json['uf'];
    branchCrjName = json['sigla'];
    companyName = json['nomeEmpresa'];
    companyGroup = json['grupoEmpresas'];
    companyAddress = json['enderecoEmpresa'];
    companyCity = json['cidadeEmpresa'];
    companyUf = json['ufEmpresa'];
    companyNeighborhood = json['bairroEmpresa'];
    companyCep = json['cepEmpresa'];
    ip = json['ip'];
    porcPromotion = json['percDesconto'];
    codSalesman = json['codVend'];
    codOffice = json['codCargo'];
    officeName = json['nomeCargo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filial'] = this.branchCrj;
    data['uf'] = this.uf;
    data['sigla'] = this.branchCrjName;
    data['nomeEmpresa'] = this.companyName;
    data['grupoEmpresas'] = this.companyGroup;
    data['enderecoEmpresa'] = this.companyAddress;
    data['cidadeEmpresa'] = this.companyCity;
    data['ufEmpresa'] = this.companyUf;
    data['bairroEmpresa'] = this.companyNeighborhood;
    data['cepEmpresa'] = this.companyCep;
    data['ip'] = this.ip;
    data['percDesconto'] = this.porcPromotion;
    data['codVend'] = this.codSalesman;
    data['codCargo'] = this.codOffice;
    data['nomeCargo'] = this.officeName;
    return data;
  }
}
