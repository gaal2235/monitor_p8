class SalesmanCode {
  String branchCarajas;
  String uf;
  String branchCarajasName;
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
      {this.branchCarajas,
        this.uf,
        this.branchCarajasName,
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
    branchCarajas = json['filial'];
    uf = json['uf'];
    branchCarajasName = json['sigla'];
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
    data['filial'] = this.branchCarajas;
    data['uf'] = this.uf;
    data['sigla'] = this.branchCarajasName;
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