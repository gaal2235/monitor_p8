class Monitor {
  String? keyNfe;
  String? branchOrigin;
  String? branchDestiny;
  String? nf;
  String? series;
  String? gfe;
  String? automobilePlate;
  String? emissionDate;
  String? daysInTransit;
  String? daysInTransitConcierge;
  String? received;
  String? checked;
  String? addressed;
  String? concierge;
  String? conciergeDate;
  String? conciergeUser;
  String? observation;
  String? entryDate;

  Monitor(
      {this.keyNfe,
        this.branchOrigin,
        this.branchDestiny,
        this.nf,
        this.series,
        this.gfe,
        this.automobilePlate,
        this.emissionDate,
        this.daysInTransit,
        this.daysInTransitConcierge,
        this.received,
        this.checked,
        this.addressed,
        this.concierge,
        this.conciergeDate,
        this.conciergeUser,
        this.observation,
        this.entryDate});

  Monitor.fromJson(Map<String, dynamic> json) {
    keyNfe = json['chaveNFE'];
    branchOrigin = json['filialOrigem'];
    branchDestiny = json['filialDestino'];
    nf = json['notaFiscal'];
    series = json['notaSerie'];
    gfe = json['romaneio'];
    automobilePlate = json['placaAutomovel'];
    emissionDate = json['dataEmissao'];
    daysInTransit = json['diasTransito'];
    daysInTransitConcierge = json['diasTransitoPortaria'];
    received = json['recebido'];
    checked = json['conferido'];
    addressed = json['enderecado'];
    concierge = json['portaria'];
    conciergeDate = json['portariaData'];
    conciergeUser = json['portariaUSR'];
    observation = json['observacao'];
    entryDate = json['dataEntrada'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['chaveNFE'] = this.keyNfe;
    data['filialOrigem'] = this.branchOrigin;
    data['filialDestino'] = this.branchDestiny;
    data['notaFiscal'] = this.nf;
    data['notaSerie'] = this.series;
    data['romaneio'] = this.gfe;
    data['placaAutomovel'] = this.automobilePlate;
    data['dataEmissao'] = this.emissionDate;
    data['diasTransito'] = this.daysInTransit;
    data['diasTransitoPortaria'] = this.daysInTransitConcierge;
    data['recebido'] = this.received;
    data['conferido'] = this.checked;
    data['enderecado'] = this.addressed;
    data['portaria'] = this.concierge;
    data['portariaData'] = this.conciergeDate;
    data['portariaUSR'] = this.conciergeUser;
    data['observacao'] = this.observation;
    data['dataEntrada'] = this.entryDate;
    return data;
  }
  static List<Monitor?> toList(List json) => json.map((e) => Monitor.fromJson(e)).toList();

}
