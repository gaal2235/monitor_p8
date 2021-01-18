class Monitor {
  String keyNfe;
  String branchOrigin;
  String branchDestiny;
  String nf;
  String nfSeries;
  String dateEmission;
  String daysInTransit;
  String daysInTransitConcierge;
  String received;
  String checked;
  String addressed;
  String concierge;
  String conciergeDate;
  String conciergeUser;
  String observation;
  String dateEntry;

  Monitor(
      {this.keyNfe,
      this.branchOrigin,
      this.branchDestiny,
      this.nf,
      this.nfSeries,
      this.dateEmission,
      this.daysInTransit,
      this.daysInTransitConcierge,
      this.received,
      this.checked,
      this.addressed,
      this.concierge,
      this.conciergeDate,
      this.conciergeUser,
      this.observation,
      this.dateEntry});

  Monitor.fromJson(Map<String, dynamic> json) {
    keyNfe = json['chaveNFE'];
    branchOrigin = json['filialOrigem'];
    branchDestiny = json['filialDestino'];
    nf = json['notaFiscal'];
    nfSeries = json['notaSerie'];
    dateEmission = json['dataEmissao'];
    daysInTransit = json['diasTransito'];
    daysInTransitConcierge = json['diasTransitoPortaria'];
    received = json['recebido'];
    checked = json['conferido'];
    addressed = json['enderecado'];
    concierge = json['portaria'];
    conciergeDate = json['portariaData'];
    conciergeUser = json['portariaUSR'];
    observation = json['observacao'];
    dateEntry = json['dataEntrada'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chaveNFE'] = this.keyNfe;
    data['filialOrigem'] = this.branchOrigin;
    data['filialDestino'] = this.branchDestiny;
    data['notaFiscal'] = this.nf;
    data['notaSerie'] = this.nfSeries;
    data['dataEmissao'] = this.dateEmission;
    data['diasTransito'] = this.daysInTransit;
    data['diasTransitoPortaria'] = this.daysInTransitConcierge;
    data['recebido'] = this.received;
    data['conferido'] = this.checked;
    data['enderecado'] = this.addressed;
    data['portaria'] = this.concierge;
    data['portariaData'] = this.conciergeDate;
    data['portariaUSR'] = this.conciergeUser;
    data['observacao'] = this.observation;
    data['dataEntrada'] = this.dateEntry;
    return data;
  }
}
