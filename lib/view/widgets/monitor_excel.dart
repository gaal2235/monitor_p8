
import 'package:essential_xlsx/essential_xlsx.dart';
import 'package:monitor_geral/model/monitor.dart';
/// Excel for Budget track report
toExcelMonitor(List<Monitor>track) async {
 // print("vvvv");

  List<Map<String, dynamic>> data = [];
  print(track);
  for (int k = 0; k < track.length; k++) {


    data.add({
      "Origem": "${track[k].branchOrigin??''}",
      "Destino": "${track[k].branchDestiny??''}",
      "Emissão": "${track[k].emissionDate??''}",
      "DiasEmTransito": "${track[k].daysInTransit??''}",
      "Nf": "${track[k].nf??''}",
      "Series": "${track[k].series??''}",
      "Entrada": "${track[k].conciergeDate??''}",
      "Pedido": "${track[k].received??''}",
      "Gfe": "${track[k].gfe??''}",
      "Descri": "${track[k].observation??''}",
      "Placa": "${track[k].automobilePlate??''}",
      "Conferencia": "${track[k].checked??''}",
      "Enderecamento": "${track[k].addressed??''}",
      "CheckP8": "${track[k].concierge??''}",
      "Recebimento": "${track[k].received??''}",
      "UserCheck": "${track[k].conciergeUser??''}",
      "HoraCheck": "${track[k].conciergeDate??''}",
    });
  }


  if (data != null) {
    if (data.isNotEmpty) {
      var simpleXLSX = SimpleXLSX();
      simpleXLSX.sheetName = 'sheet';

      var idx = 0;
      data.forEach((item) {
        if (idx == 0) {
          simpleXLSX.addRow(item.keys.toList());
        }
        {
          simpleXLSX.addRow(item.values.map((i) => i.toString()).toList());
        }
        idx++;
      });

      simpleXLSX.build();
    }
  }

  return true;
}
