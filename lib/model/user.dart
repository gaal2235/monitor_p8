class User {
  String userCode;
  String user;
  String name;
  String department;
  String office;
  String email;
  String token;
  List<OperatorWMS> operatorWms;
  List<SalesmanCode> salesmanCode;

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
      operatorWms = new List<OperatorWMS>();
      json['operadorWMS'].forEach((v) {
        operatorWms.add(new OperatorWMS.fromJson(v));
      });
    }
    if (json['codVend'] != null) {
      salesmanCode = new List<SalesmanCode>();
      json['codVend'].forEach((v) {
        salesmanCode.add(new SalesmanCode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codUser'] = this.userCode;
    data['user'] = this.user;
    data['nome'] = this.name;
    data['depart'] = this.department;
    data['cargo'] = this.office;
    data['email'] = this.email;
    data['token'] = this.token;
    if (this.operatorWms != null) {
      data['operadorWMS'] = this.operatorWms.map((v) => v.toJson()).toList();
    }
    if (this.salesmanCode != null) {
      data['codVend'] = this.salesmanCode.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OperatorWMS {
  String branchOperator;
  String branchOperatorName;
  String statusOperator;
  String usrOperatorCode;

  OperatorWMS(
      {this.branchOperator,
      this.branchOperatorName,
      this.statusOperator,
      this.usrOperatorCode});

  OperatorWMS.fromJson(Map<String, dynamic> json) {
    branchOperator = json['filialOperador'];
    branchOperatorName = json['siglaFilialOperador'];
    statusOperator = json['statusOperador'];
    usrOperatorCode = json['codUsrOperador'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filialOperador'] = this.branchOperator;
    data['siglaFilialOperador'] = this.branchOperatorName;
    data['statusOperador'] = this.statusOperator;
    data['codUsrOperador'] = this.usrOperatorCode;
    return data;
  }
}

class SalesmanCode {
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
  dynamic discountPercentage;
  String salesmanCode;
  String officeCode;
  String officeName;

  SalesmanCode(
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
      this.discountPercentage,
      this.salesmanCode,
      this.officeCode,
      this.officeName});

  SalesmanCode.fromJson(Map<String, dynamic> json) {
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
    discountPercentage = json['percDesconto'];
    salesmanCode = json['codVend'];
    officeCode = json['codCargo'];
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
    data['percDesconto'] = this.discountPercentage;
    data['codVend'] = this.salesmanCode;
    data['codCargo'] = this.officeCode;
    data['nomeCargo'] = this.officeName;
    return data;
  }
}
