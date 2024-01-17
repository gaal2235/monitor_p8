class OperatorWMS {
  String? branchOperator;
  String? branchOperatorName;
  String? statusOperator;
  String? usrOperatorCode;

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
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['filialOperador'] = this.branchOperator;
    data['siglaFilialOperador'] = this.branchOperatorName;
    data['statusOperador'] = this.statusOperator;
    data['codUsrOperador'] = this.usrOperatorCode;
    return data;
  }
}