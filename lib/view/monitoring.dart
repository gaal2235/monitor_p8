import 'dart:async';

import 'package:clippy/browser.dart' as clippy;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monitor_geral/controller/monitor.dart';
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:monitor_geral/view/widgets/date.dart';
import 'package:monitor_geral/view/widgets/monitor_excel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/concierge.dart';

class Monitoring extends StatefulWidget {
  @override
  _MonitoringState createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {

  bool auditorP8 = true;
  final _searchGfe = TextEditingController();
  final _searchPlate = TextEditingController();
  var plate = "";
  var gfe = "";
  final _streamController = StreamController<List<Monitor>>.broadcast();
  final _streamController2 = StreamController<List<Monitor>>.broadcast();
  final _streamController3 = StreamController<List<Monitor>>.broadcast();
  final _streamController4 = StreamController<List<Monitor>>.broadcast();
  Timer timer;
  final interval = Duration(seconds: 1);
  var pl = FocusNode();
  var nf = FocusNode();
  final int timerMaxSeconds = 1200;

  int currentSeconds = 0;
  final _nfCode = TextEditingController();
  bool nfValidator = true;
  bool progress = false;
  bool loadAta = false;
  bool plateValidator = true;
  List<Monitor> monitor = [];
  bool fst = true;
  int audited = 0;

  MaskedTextController _fromDateController = MaskedTextController(
    mask: '00/00/0000',
    text: DateFormat('ddMMyyyy').format(DateTime.now()),
  );
  MaskedTextController _toDateController = MaskedTextController(
    mask: '00/00/0000',
    text: DateFormat('ddMMyyyy').format(DateTime.now()),
  );
  StreamController _streamLoad = StreamController.broadcast();
  StreamController _streamLoadOut = StreamController.broadcast();
  bool load = false;
  final _streamControllerGeneral = StreamController<List<Monitor>>.broadcast();

  List<Monitor> monitorData;
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(
            2,
            '0',
          )}:'
      ' ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(
            2,
            '0',
          )}';

  startTimeout([int milliseconds]) {
    var duration = interval;

    timer = Timer.periodic(duration, (timer) {

      if (!loadAta) {
        if (mounted) {
          setState(() {
            currentSeconds = timer.tick;
            if (timer.tick >= timerMaxSeconds) {
              currentSeconds = 0;
              _loadData();
              timer.cancel();
            }
          });
        }
      }else{
        if (mounted) {
          setState(() {
            currentSeconds = timer.tick;
            if (timer.tick >= timerMaxSeconds) {
              timer.cancel();
              startTimeout();
            }
          });
        }
      }
    });
  }


  @override
  void initState() {

   // startTimeout();
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorApp[800],
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(
              (
                  user.user=="cezarbatista"||
                  user.user=="marlielsongomes"||
                  user.user=="jeansousa"||
                  user.user=="danielsampaio"||
                  user.userCode=="002291"||
                  user.userCode=="000001"||
                      user.user=="gabrielsilva"
              )&&
              dropdownValue.toString().substring(0, 4)=="0110"||
                  dropdownValue.toString().substring(0, 4)=="0107"||
                  dropdownValue.toString().substring(0, 4)=="0109"||
                  dropdownValue.toString().substring(0, 4)=="0116"
              )...{StreamBuilder(
                  stream: _streamController3.stream,
                  builder: (context, snapshot) {
                    return Container(
                      margin: EdgeInsets.all(5),

                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.green[800],)),
                        onPressed: () async {
                          loadAta = true;
                          showGeneralDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.black45,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                int total = 0;
                                return StreamBuilder(
                                    stream: _streamController4.stream,
                                    builder: (context, snapshot) {
                                      return Material(
                                          color: Colors.black.withOpacity(0.5),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Image.asset(
                                                  colorApp==Colors.green?
                                                  'assets/P8O.png':'assets/P8.png',
                                                  width: MediaQuery.of(context).size.width * 0.2,

                                                  alignment: Alignment.center,
                                                ),
                                                Text(
                                                  'Aguarde a finalização da auditoria das notas de atacado...\nTotal de notas de atacado auditadas: $total',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                      25
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ));
                                    }
                                );
                              });
                          _streamController3.add(null);
                          bool f = false;
                          for (audited = 0; audited<monitor.length;audited++) {

                            if(
                            (monitor[audited].branchOrigin=="0112"&&monitor[audited].branchDestiny=="0109"&&monitor[audited].concierge!="S")||
                                (monitor[audited].branchOrigin=="0115"&&monitor[audited].branchDestiny=="0116"&&monitor[audited].concierge!="S")||
                                (monitor[audited].branchOrigin=="0111"&&monitor[audited].branchDestiny=="0107"&&monitor[audited].concierge!="S")||
                                (monitor[audited].branchOrigin=="0102"&&monitor[audited].branchDestiny=="0110"&&monitor[audited].concierge!="S")
                            ){
                              f = true;
                              total++;
                              gfe = monitor[audited].gfe;
                              plate = monitor[audited].automobilePlate;
                              nfCode = monitor[audited].keyNfe;
                              await Concierge.postConcierge(ori: monitor[audited].branchOrigin);
                              _streamController4.add(null);
                            }
                          }

                          Navigator.pop(context);
                          if(!f){
                            showGeneralDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.black45,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return StreamBuilder(
                                      stream: _streamController4.stream,
                                      builder: (context, snapshot) {
                                        return Material(
                                            color: Colors.black.withOpacity(0.5),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Image.asset(
                                                    colorApp==Colors.green?
                                                    'assets/P8O.png':'assets/P8.png',
                                                    width: MediaQuery.of(context).size.width * 0.2,

                                                    alignment: Alignment.center,
                                                  ),
                                                  Text(
                                                    'Não há nenhuma nota de atacado pendente\nde auditoria no momento',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                        25
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      }
                                  );
                                });
                            await Future.delayed(Duration(seconds: 5));
                            Navigator.pop(context);
                          }
                          _loadData();
                          loadAta = false;
                          _streamController3.add(null);
                        },
                        padding: EdgeInsets.all(10.0),
                        color: Colors.white,
                        textColor: Colors.green[800],
                        child:loadAta?Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]),
                            ),
                          ),
                        ): Text("  Auditar Notas de Atacado  ",

                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,)),
                      ),
                    );
                  }
              ),},
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: DropdownButton<String>(
                  dropdownColor: colorApp[800],
                  value: dropdownValue,
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: colorApp,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Monitoring(),
                        ),
                      );
                    });
                  },
                  items: <String>[
                    branchCrj(0),
                    branchCrj(1),
                    branchCrj(2),
                    branchCrj(3),
                    branchCrj(4),
                    branchCrj(5),
                    branchCrj(6),
                    branchCrj(7),
                    branchCrj(8),
                    branchCrj(9),
                    branchCrj(10),
                    branchCrj(11),
                    branchCrj(12),
                    branchCrj(13),
                    branchCrj(14),
                    branchCrj(15),
                    branchCrj(16),
                  ].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Theme(
                        data: ThemeData(
                          primaryColor: Colors.white,
                          cursorColor: Colors.white,
                          disabledColor: Colors.white,
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: TextFormField(
                          controller: _searchGfe,
                          maxLength: 8,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: "Romaneio",
                            isDense: true,
                            counterText: "",
                          ),
                          onChanged: (value) {
                            if (value.length == 8) {
                              gfe = "";
                              setState(() {
                                if (_searchGfe.text.length == 8) {
                                  gfe = _searchGfe.text;
                                  _loadData();
                                  pl.requestFocus();
                                }
                              });
                            }
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            this.setState(() {
                              _searchGfe.clear();
                              gfe = "";
                            });

                            _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Theme(
                        data: ThemeData(
                          primaryColor: Colors.white,
                          cursorColor: Colors.white,
                          disabledColor: Colors.white,
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: TextFormField(
                          focusNode: pl,
                          maxLength: 7,
                          controller: _searchPlate,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            if (value.length == 7) {
                              plate = "";

                              setState(() {
                                if (_searchPlate.text.length == 7) {
                                  plate = _searchPlate.text;
                                  _loadData();
                                }
                              });
                            }
                          },
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(color: Colors.white),
                            hintText: "Placa",
                            isDense: true,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            this.setState(
                              () {
                                _searchPlate.clear();

                                plate = "";
                              },
                            );

                            _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              FlatButton(
                onPressed: () async {
                  if(dateInit==null){dateInit= DateTime.parse(DateFormat('yyyyMMdd').format(
                    DateTime.now().subtract(Duration(days: 30)),
                  ));}
                  dateInit = await getDate(context, dateInit);
                  dataInitForm = DateFormat('yyyyMMdd').format(
                    dateInit,
                  );

                  setState(() {
                    _loadData();
                    dataInitForm = DateFormat('yyyyMMdd').format(
                      dateInit,
                    );
                  });

                },
                child: Stack(children: <Widget>[
                  dateInit == null
                      ? Row(
                          children: [
                            Text(
                                'De: ${DateFormat('dd/MM/yyyy').format(
                                  DateTime.now(),
                                )}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.02,
                                )),
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                                'De: ${DateFormat('dd/MM/yyyy').format(
                                  dateInit,
                                )}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.02,
                                )),
                          ],
                        )
                ]),
              ),
              FlatButton(
                onPressed: () async {
                  if(dateEnd==null){dateEnd= DateTime.parse(DateFormat('yyyyMMdd').format(
                    DateTime.now(),
                  ));}
                  dateEnd = await getDate(context, dateEnd);
                  dateEndForm = DateFormat('yyyyMMdd').format(
                    dateEnd,
                  );
                  setState(() {
                    _loadData();
                    dateEndForm = DateFormat('yyyyMMdd').format(
                      dateEnd,
                    );
                  });

                },
                child: Stack(
                  children: <Widget>[
                    dateEnd == null
                        ? Row(
                            children: [

                              Text(
                                  "Até: ${DateFormat('dd/MM/yyyy').format(
                                    DateTime.now(),
                                  )}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.02,
                                  )),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                "Até: "
                                "${DateFormat('dd/MM/yyyy').format(
                                  dateEnd,
                                )}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.02,
                                ),
                              ),
                            ],
                          )
                  ],
                ),
              ),

              GestureDetector(
                  onTap: () async {
                    if(!load){
                    load = true;
                    _streamLoadOut.add(85);
                    await toExcelMonitor(monitorData);

                    load = false;
                    _streamLoadOut.add(85);
                    }
                  },
                  child: StreamBuilder(
                      stream: _streamLoadOut.stream,
                      builder: (context, snapshot) {
                        return !load
                            ? Icon(MdiIcons.microsoftExcel)
                            : Container(
                          width: 20,
                              height: 20,
                              child: Center(
                                  child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                )),
                            );
                      })),

              SizedBox(
                width: 8,
              ),
              Icon(Icons.timer),
              SizedBox(
                width: 5,
              ),
              //Text("Tempo desde a ultima atualização: "),
              Text(timerText),

              SizedBox(
                width: 20,
              ),
            ],
          )
        ],
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Monitoring(),
                  ),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/P8.png',
                    width: MediaQuery.of(
                          context,
                        ).size.width *
                        0.1,
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
              stream: _streamController.stream,
              builder: (
                BuildContext context,
                AsyncSnapshot snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            bottom: 8,
                            left: 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: auditorP8
                                    ? Colors.green[900]
                                    : Colors.red[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: auditorP8
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.truckCheckOutline,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Container(
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.015,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueGrey[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.blueGrey[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.textBoxCheckOutline,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Container(
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.015,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                            bottom: 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.cyan[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  5.0,
                                ),
                              ),
                              color: Colors.cyan[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.import,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Container(
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.015,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 8,
                            top: 8.0,
                            bottom: 8,
                            right: 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  5.0,
                                ),
                              ),
                              color: Colors.teal[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.transfer,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                              2.0,
                                            ),
                                            child: Container(
                                              height: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.03,
                                              width: MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.015,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            8,
                            8,
                            8.0,
                          ),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueGrey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    5.0,
                                  ),
                                ),
                                color: Colors.indigo[800],
                              ),
                              height: MediaQuery.of(
                                    context,
                                  ).size.height *
                                  0.15,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          MdiIcons.chartBarStacked,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Quantidade",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.018,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Container(
                                                height: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.03,
                                                width: MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.015,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height: MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.001,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 4.0),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Total",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.022,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                onDay = 0;
                conference = 0;
                pending = 0;
                address = 0;
                total = 0;
                p8 = 0;

                List<Monitor> monitor2 = snapshot.data;
                registry = monitor2.length;
                for (int t = 0; t < monitor2.length; t++) {
                  if (monitor2[t].checked == "S") {
                    conference++;
                  }
                  if (monitor2[t].received == "S") {
                    pending++;
                  }
                  if (monitor2[t].addressed == "S") {
                    address++;
                  }
                  if (auditorP8) {
                    if (monitor2[t].concierge == "S") {
                      p8++;
                    }
                  } else {
                    if (monitor2[t].concierge == "N") {
                      p8++;
                    }
                  }
                  if (monitor2[t].daysInTransit != " DD" &&
                      monitor2[t].daysInTransit != "0 DD" &&
                      monitor2[t].daysInTransit != "1 DD") {
                    onDay++;
                  }
                }
                total = totalCollections;
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 8,
                          left: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                if (colorApp == Colors.green ||
                                    colorApp == Colors.red) {
                                  auditorP8 = !auditorP8;
                                }

                                if (auditorP8) {
                                  if (colorApp != Colors.green) {
                                    colorApp = Colors.green;
                                  }
                                  received = "";
                                  checked = "";
                                  addressed = "";
                                  concierge = "S";
                                  _loadDataFilter();
                                } else {
                                  if (colorApp != Colors.red) {
                                    colorApp = Colors.red;
                                  }
                                  received = "";
                                  checked = "";
                                  addressed = "";
                                  concierge = "N";
                                  _loadDataFilter();
                                }
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: auditorP8
                                    ? Colors.green[900]
                                    : Colors.red[800],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: auditorP8
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          !auditorP8
                                              ? Icon(
                                                  MdiIcons.truckFastOutline,
                                                  color: Colors.white,
                                                  size: 40,
                                                )
                                              : Icon(
                                                  MdiIcons.truckCheckOutline,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                          colorApp == Colors.green ||
                                                  colorApp == Colors.red
                                              ? Center(
                                                  child: Icon(
                                                    MdiIcons.autorenew,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "$p8",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Row(

                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: auditorP8
                                                  ? Text(
                                                      "Auditados P8",
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.022,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Pendentes de Auditoria P8",
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.022,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueGrey[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.blueGrey[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.textBoxCheckOutline,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "...",
                                              //"$conferencia",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Pendente conferência",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 8,
                          right: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (colorApp != Colors.cyan) {
                                colorApp = Colors.cyan;
                              }
                              received = "S";
                              checked = "";
                              addressed = "";
                              concierge = "";
                              _loadDataFilter();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.cyan[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.cyan[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.import,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "$pending",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Entrada NF Realizada",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 8,
                          right: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            /* setState(() {
                                if (emtranspad != Colors.teal) {
                                  emtranspad = Colors.teal;
                                }
                                recebido = "";
                                conferido = "";
                                enderecado = "S";
                                portaria = "";
                                _loadDataFiltro();
                              });*/
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.teal[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.transfer,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "...",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Pendente endereçamento",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          8,
                          8,
                          8.0,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              if (colorApp != Colors.indigo) {
                                colorApp = Colors.indigo;
                              }
                              received = "";
                              checked = "";
                              addressed = "";
                              concierge = "";
                              _loadData();
                            });
                            showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.03,
                                  width: MediaQuery.of(
                                        context,
                                      ).size.width *
                                      0.015,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                            await _loadDataGeneral();

                            Navigator.of(context).pop();

                            alertGeneral(_loadDataGeneral, context, date, line,
                                lineTotal, monitorData, _streamLoad, load);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueGrey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.indigo[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.15,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.chartBarStacked,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Quantidade",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                "$total",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.025,
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.001,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Total",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.022,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: colorApp == Colors.green
                        ? EdgeInsets.only(left: 8, right: 8)
                        : EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorApp[900],
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0),
                        ),
                        color: colorApp[800],
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Portal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Origem",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Destino",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Emissão",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Dias",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Nota Fiscal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Serie",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Entrada",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Pedido",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Descrição",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Status",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: colorApp == Colors.green
                                    ? MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.018
                                    : MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.022,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: colorApp == Colors.green
                            ? EdgeInsets.only(
                                bottom: 8.0,
                                left: 8,
                                right: 8,
                              )
                            : EdgeInsets.only(
                                bottom: 8.0,
                                left: 8,
                                right: 8,
                              ),
                        child: Container(
                          width: MediaQuery.of(
                            context,
                          ).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorApp,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: StreamBuilder(
                              stream: _streamController.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Image.asset(
                                      'assets/gif1.gif',
                                      color: colorApp,
                                      height: 70,
                                    ),
                                  );
                                }
                                monitorData = snapshot.data;
                                if (monitorData.isEmpty) {
                                  return Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        MdiIcons.clipboardOutline,
                                        color: colorApp,
                                        size: MediaQuery.of(
                                              context,
                                            ).size.width *
                                            0.05,
                                      ),
                                      SizedBox(
                                        height: MediaQuery.of(
                                              context,
                                            ).size.width *
                                            0.01,
                                      ),
                                      Text(
                                        "Não ha registros",
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.015,
                                            color: colorApp),
                                      ),
                                    ],
                                  ));
                                }
                                return Scrollbar(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: monitorData.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      Monitor m = monitorData[index];
                                      key.add(m.keyNfe);

                                      return Column(
                                        children: [
                                          lineMonitor(
                                            key.length,
                                            m.branchOrigin,
                                            m.branchDestiny,
                                            m.nf,
                                            m.series,
                                            m.observation,
                                            m.emissionDate,
                                            m.entryDate,
                                            m.emissionDate,
                                            m.daysInTransit,
                                            GestureDetector(
                                              onTap: () {
                                                register(m);
                                              },
                                              child: m.concierge == "N"
                                                  ? iconStatus(
                                                      alertDetailsStatus(),
                                                      Colors.red[800],
                                                      MdiIcons.truckFastOutline,
                                                    )
                                                  : iconStatus(
                                                      alertDetailsStatus(),
                                                      Colors.green[800],
                                                      MdiIcons
                                                          .truckCheckOutline,
                                                    ),
                                            ),
                                            m.checked == "S"
                                                ? iconStatus(
                                                    alertDetailsStatus(),
                                                    Colors.blueGrey[800],
                                                    MdiIcons
                                                        .textBoxCheckOutline,
                                                  )
                                                : Container(),
                                            m.received == "S"
                                                ? iconStatus(
                                                    alertDetailsStatus(),
                                                    Colors.cyan[800],
                                                    MdiIcons.import,
                                                  )
                                                : Container(),
                                            m.addressed == "S"
                                                ? Container()
                                                : Container(),
                                          ),
                                          lineSeparation(),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///atualiza monitor p8
  _loadData() async {
    _streamController.add(null);

     monitor = await MonitorManagement.getMonitor(
      received: "",
      checked: "",
      addressed: "",
      concierge: "",
      dateInit: "$dataInitForm",
      dateEnd: "$dateEndForm",
      plate: plate.toUpperCase(),
      gfe: gfe,
    );

    totalCollections = monitor.length;
    startTimeout();
    _streamController.add(monitor);
  }

  ///atualiza monitor geral p8
  _loadDataGeneral() async {
    general0101 = [0, 0, 0, 0, 0];
    general0103 = [0, 0, 0, 0, 0];
    general0104 = [0, 0, 0, 0, 0];
    general0105 = [0, 0, 0, 0, 0];
    general0106 = [0, 0, 0, 0, 0];
    general0107 = [0, 0, 0, 0, 0];
    general0108 = [0, 0, 0, 0, 0];
    general0109 = [0, 0, 0, 0, 0];
    general0110 = [0, 0, 0, 0, 0];
    general0111 = [0, 0, 0, 0, 0];
    general0113 = [0, 0, 0, 0, 0];
    general0114 = [0, 0, 0, 0, 0];
    general0115 = [0, 0, 0, 0, 0];
    general0116 = [0, 0, 0, 0, 0];
    totalGeneral = 0;
    _streamControllerGeneral.add(null);
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.03,
            width: MediaQuery.of(context).size.width * 0.015,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        });

    monitorGeneral = await MonitorManagement.getMonitor(
      dateInit: "$dataInitFormGeneral",
      dateEnd: "$dateEndFormGeneral",
        noBranch:true

    );

    for (int i = 0; i < monitorGeneral.length; i++) {
      totalGeneral++;
      if (monitorGeneral[i].branchDestiny == "0101") {
        if (monitorGeneral[i].concierge == "S") {
          general0101[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0101[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0101[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0103") {
        if (monitorGeneral[i].concierge == "S") {
          general0103[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0103[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0103[4]++;
      }else if (monitorGeneral[i].branchDestiny == "0114") {
        if (monitorGeneral[i].concierge == "S") {
          general0114[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0114[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0114[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0111") {
        if (monitorGeneral[i].concierge == "S") {
          general0111[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0111[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0111[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0115") {
        if (monitorGeneral[i].concierge == "S") {
          general0115[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0115[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0115[4]++;
      }else if (monitorGeneral[i].branchDestiny == "0102") {
        if (monitorGeneral[i].concierge == "S") {
          general0102[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0102[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0102[4]++;
      }else if (monitorGeneral[i].branchDestiny == "0116") {
        if (monitorGeneral[i].concierge == "S") {
          general0116[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0116[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0116[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0104") {
        if (monitorGeneral[i].concierge == "S") {
          general0104[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0104[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0104[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0105") {
        if (monitorGeneral[i].concierge == "S") {
          general0105[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0105[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0105[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0106") {
        if (monitorGeneral[i].concierge == "S") {
          general0106[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0106[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0106[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0107") {
        if (monitorGeneral[i].concierge == "S") {
          general0107[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0107[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0107[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0108") {
        if (monitorGeneral[i].concierge == "S") {
          general0108[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0108[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0108[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0109") {
        if (monitorGeneral[i].concierge == "S") {
          general0109[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0109[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0109[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0110") {
        if (monitorGeneral[i].concierge == "S") {
          general0110[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0110[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0110[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0112") {
        if (monitorGeneral[i].concierge == "S") {
          general0112[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0112[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0112[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0113") {
        if (monitorGeneral[i].concierge == "S") {
          general0113[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0113[1]++;
        }
        if (monitorGeneral[i].checked == "S") {}
        if (monitorGeneral[i].addressed == "S") {}
        general0113[4]++;
      }
    }

    Navigator.of(context).pop();
    _streamControllerGeneral.add(monitorGeneral);
  }

  ///filtra monitor p8
  _loadDataFilter() async {
    _streamController.add(null);

    List<Monitor> monitor = await MonitorManagement.getMonitor(
      received: "$received",
      checked: "$checked",
      addressed: "$addressed",
      concierge: "$concierge",
      dateInit: "$dataInitForm",
      dateEnd: "$dateEndForm",
      plate: plate.toUpperCase(),
      gfe: gfe,
    );

    _streamController.add(monitor);
  }

  ///alerta de detalhes
  alertDetailsStatus() {}

  line(index, text, general) {
    return StreamBuilder(
      stream: _streamControllerGeneral.stream,
      builder: (
        BuildContext context,
        AsyncSnapshot snapshot,
      ) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorApp,
                  width: 0.5,
                ),
                color: Colors.white,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp,
                            ),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              "${general[0]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              "${general[2]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              '${general[1]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              "${general[3]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp[800],
                            ),
                            child: Text(
                              "${general[4]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  lineTotal(index, text) {
    return StreamBuilder(
      stream: _streamControllerGeneral.stream,
      builder: (
        BuildContext context,
        AsyncSnapshot snapshot,
      ) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorApp,
                  width: 0.5,
                ),
                color: Colors.white,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                              ),
                              color: colorApp[800],
                            ),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp[800],
                            ),
                            child: valueBranch(0),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp[800],
                            ),
                            child: valueBranch(2),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp[800],
                            ),
                            child: valueBranch(1),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              color: colorApp[800],
                            ),
                            child: valueBranch(3),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5.0),
                              ),
                              color: colorApp[800],
                            ),
                            child: Text(
                              "$totalGeneral",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  lineSeparation() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.001,
      width: MediaQuery.of(context).size.width,
      color: colorApp,
    );
  }

  lineMonitor(
      int count,
      String origin,
      String destiny,
      String nf,
      String series,
      String operation,
      String request,
      String input,
      String emission,
      String day,
      dynamic inTransit,
      dynamic checkP8,
      dynamic addressed,
      dynamic checked) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
                onTap: () {
                  launchURL(key[count]);
                },
                child: Icon(
                  MdiIcons.magnify,
                  color: colorApp,
                )),
          ),
          Expanded(
              flex: 1,
              child: Text(
                origin,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )),
          Expanded(
              flex: 1,
              child: Text(
                destiny,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )),
          Expanded(
            flex: 2,
            child: Text(
              emission,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () async {
                      await clippy.write(nf);
                    },
                    child: Icon(
                      MdiIcons.noteMultipleOutline,
                      color: colorApp,
                    )),
                SizedBox(
                  width: 5,
                ),
                Text(
                  nf,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              series,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              input,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              request,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              operation,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                inTransit,
                checkP8,
                addressed,
                checked,
              ],
            ),
          ),
        ],
      ),
    );
  }

  lineMonitorCheck(
      int count,
      String origin,
      String destiny,
      String nf,
      String series,
      String input,
      String emission,
      String day,
      dynamic inTransit,
      dynamic checkP8,
      dynamic addressed,
      dynamic checked) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
                onTap: () {
                  launchURL(key[count]);
                },
                child: Icon(
                  MdiIcons.magnify,
                  color: colorApp,
                )),
          ),
          Expanded(
              flex: 1,
              child: Text(
                origin,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )),
          Expanded(
              flex: 1,
              child: Text(
                destiny,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )),
          Expanded(
            flex: 2,
            child: Text(
              emission,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () async {
                      await clippy.write(nf);
                    },
                    child: Icon(
                      MdiIcons.noteMultipleOutline,
                      color: colorApp,
                    )),
                SizedBox(
                  width: 5,
                ),
                Text(
                  nf,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              series,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              input,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                inTransit,
              ],
            ),
          ),
        ],
      ),
    );
  }

  launchURL(String key) async {
    var url = 'http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?'
        'tipoConteudo=XbSeqxE8pl8=&tipoConsulta=completa&nfe=$key&';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void register(Monitor m) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            title: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: m.concierge == "N"
                                  ? Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            MdiIcons.truckFastOutline,
                                            color: Colors.red[800],
                                          ),
                                          Text(
                                            "Auditoria P8",
                                            style: TextStyle(
                                                color: Colors.red[800],
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            MdiIcons.truckCheckOutline,
                                            color: Colors.green[800],
                                          ),
                                          Text(
                                            "Auditoria P8",
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: m.concierge == "N"
                                        ? Colors.grey
                                        : Colors.green,
                                    width: MediaQuery.of(
                                      context,
                                    ).size.width,
                                    height: MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.005,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                    color: m.concierge == "N"
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "${m.conciergeDate}",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "${m.conciergeUser}",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      MdiIcons.textBoxCheckOutline,
                                      color: Colors.blueGrey[800],
                                    ),
                                    Text(
                                      "Conferência",
                                      style: TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: m.checked == "S"
                                        ? Colors.green
                                        : Colors.grey,
                                    width: MediaQuery.of(
                                      context,
                                    ).size.width,
                                    height: MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.005,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                    color: m.checked == "S"
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      MdiIcons.import,
                                      color: Colors.cyan[800],
                                    ),
                                    Text(
                                      "Entrada NF",
                                      style: TextStyle(
                                          color: Colors.cyan[800],
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: m.received == "S"
                                        ? Colors.green
                                        : Colors.grey,
                                    width: MediaQuery.of(
                                      context,
                                    ).size.width,
                                    height: MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.005,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                    color: m.received == "S"
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      MdiIcons.transfer,
                                      color: Colors.teal[800],
                                    ),
                                    Text(
                                      "Endereçamento",
                                      style: TextStyle(
                                        color: Colors.teal[800],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: m.addressed == "S"
                                        ? Colors.grey
                                        : Colors.green,
                                    width: MediaQuery.of(
                                      context,
                                    ).size.width,
                                    height: MediaQuery.of(
                                          context,
                                        ).size.height *
                                        0.005,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                    color: m.addressed == "S"
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  date(var date, text) {
    return Stack(
      children: <Widget>[
        date == null
            ? Row(
                children: [
                  // Icon(Icons.calendar_today,color: Colors.white,),
                  Text(
                      '$text: ${DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.now())}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      )),
                ],
              )
            : Row(
                children: [
                  // Icon(Icons.calendar_today,color: Colors.white,),
                  Text('$text: ${DateFormat('dd/MM/yyyy').format(date)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      )),
                ],
              ),
      ],
    );
  }
}

alertGeneral(_loadDataGeneral(), context, date, line, lineTotal, monitorData,
    _streamLoad, load) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          // Navigator.of(context).pop();
        },
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.white,
              title: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                            8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                  dateEndForm = "${DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    DateTime.now(),
                                  )}";
                                  dataInitForm = "${DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    DateTime.now(),
                                  )}";
                                  dateInitGeneral= DateTime.parse(DateFormat('yyyyMMdd').format(
                                    DateTime.now(),
                                  ));
                                  dateEndGeneral= DateTime.parse(DateFormat('yyyyMMdd').format(
                                    DateTime.now(),
                                  ));
                                  dateEndFormGeneral = "${DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    DateTime.now(),
                                  )}";
                                  dataInitFormGeneral = "${DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    DateTime.now(),
                                  )}";
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.clear),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "Fechar",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 10,
                                    ),
                                    //Text(timerText),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FlatButton(
                              onPressed: () async {
                                if(dateInitGeneral==null){dateInitGeneral= DateTime.parse(DateFormat('yyyyMMdd').format(
                                  DateTime.now(),
                                ));}
                                dateInitGeneral = await getDate(context, dateInitGeneral);
                                dataInitFormGeneral = DateFormat('yyyyMMdd').format(
                                  dateInitGeneral,
                                );
                                setState(() {
                                  //  dateEndGeneral = dateEndGeneralController;
                                  dataInitFormGeneral = DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    dateInitGeneral,
                                  );
                                  _loadDataGeneral();

                                });

                                /*  DatePicker.showDatePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime(
                                      1999,
                                    ),
                                    maxTime: DateTime(
                                      2050,
                                    ), onChanged: (
                                  dateInitGeneralController,
                                ) {
                                  dateInitGeneralController =
                                      dateInitGeneralController;
                                  dataInitFormGeneral = DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    dateInitGeneral,
                                  );
                                }, onConfirm: (
                                  dateInitGeneralController,
                                ) {
                                  setState(
                                    () {
                                      dateInitGeneral =
                                          dateInitGeneralController;

                                      dataInitFormGeneral = DateFormat(
                                        'yyyyMMdd',
                                      ).format(
                                        dateInitGeneral,
                                      );
                                      _loadDataGeneral();
                                    },
                                  );
                                },
                                    currentTime: dateInitGeneral,
                                    locale: LocaleType.pt);*/
                              },
                              child: date(dateInitGeneral, "De"),
                            ),
                            FlatButton(
                              onPressed: () async {
            if(dateEndGeneral==null){dateEndGeneral= DateTime.parse(DateFormat('yyyyMMdd').format(
            DateTime.now(),
            ));}
            dateEndGeneral = await getDate(context, dateEndGeneral);
            dateEndFormGeneral = DateFormat('yyyyMMdd').format(
              dateEndGeneral,
            );
            setState(() {
            //  dateEndGeneral = dateEndGeneralController;
              dateEndFormGeneral = DateFormat(
                'yyyyMMdd',
              ).format(
                dateEndGeneral,
              );
              _loadDataGeneral();

            });


                                /*DatePicker.showDatePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime(
                                      1999,
                                    ),
                                    maxTime: DateTime(
                                      2050,
                                    ), onChanged: (
                                  dateEndGeneralController,
                                ) {
                                  dateEndGeneral = dateEndGeneralController;
                                  dateEndFormGeneral = DateFormat(
                                    'yyyyMMdd',
                                  ).format(
                                    dateEndGeneralController,
                                  );
                                }, onConfirm: (
                                  dateEndGeneralController,
                                ) {
                                  setState(
                                    () {
                                      dateEndGeneral = dateEndGeneralController;
                                      dateEndFormGeneral = DateFormat(
                                        'yyyyMMdd',
                                      ).format(
                                        dateEndGeneral,
                                      );
                                      _loadDataGeneral();
                                    },
                                  );
                                },
                                    currentTime: dateEndGeneral,
                                    locale: LocaleType.pt);*/
                              },
                              child: date(dateEndGeneral, "Até"),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await _loadDataGeneral();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(
                                  8.0,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),

                                    Icon(
                                      Icons.refresh,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "Atualizar",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    StreamBuilder(
                                        stream: _streamLoad.stream,
                                        builder: (context, snapshot) {
                                          return GestureDetector(
                                            onTap: () async {
                                              if(!load){
                                              load = true;
                                              _streamLoad.add(123);
                                              await toExcelMonitor(
                                                  monitorGeneral.isNotEmpty
                                                      ? monitorGeneral
                                                      : monitorData);
                                              load = false;
                                              _streamLoad.add(123);
                                              }
                                            },
                                            child: !load
                                                ? Icon(MdiIcons.microsoftExcel)
                                                : Container(
                                              width: 20,
                                              height: 20,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    ),
                                                ),
                                          );
                                        }),
                                    //Text(timerText),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.indigo,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                          ),
                          color: Colors.indigo[400],
                        ),
                        width: MediaQuery.of(
                          context,
                        ).size.width,
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                color: colorApp,
                                child: Center(
                                  child: Text(
                                    "FILIAL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: MediaQuery.of(
                                context,
                              ).size.height,
                              color: colorApp,
                            ),
                            Expanded(
                              child: Text(
                                "Auditoria P8",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: MediaQuery.of(context).size.height,
                              color: colorApp,
                            ),
                            Expanded(
                              child: Text(
                                "CONFERÊNCIA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: MediaQuery.of(context).size.height,
                              color: colorApp,
                            ),
                            Expanded(
                              child: Text(
                                "ENTRADA NF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: MediaQuery.of(
                                context,
                              ).size.height,
                              color: colorApp,
                            ),
                            Expanded(
                              child: Text(
                                "ENDEREÇAMENTO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: MediaQuery.of(
                                context,
                              ).size.height,
                              color: colorApp,
                            ),
                            Expanded(
                              child: Container(
                                height: MediaQuery.of(
                                  context,
                                ).size.height,
                                color: colorApp[800],
                                child: Center(
                                  child: Text(
                                    "TOTAL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    line(
                      0,
                      "MCZ - 0101",
                      general0101,
                    ),
                    line(
                      1,
                      "ARA - 0103",
                      general0103,
                    ),
                    line(
                      2,
                      "JPA - 0104",
                      general0104,
                    ),
                    line(
                      3,
                      "CD - 0105",
                      general0105,
                    ),
                    line(
                      4,
                      "CGD - 0106",
                      general0106,
                    ),
                    line(
                      5,
                      "NAT - 0107",
                      general0107,
                    ),
                    line(
                      6,
                      "CBD - 0108",
                      general0108,
                    ),
                    line(
                      7,
                      "FOR - 0109",
                      general0109,
                    ),
                    line(
                      8,
                      "JUA - 0110",
                      general0110,
                    ),
                    line(
                      9,
                      "DVM - 0113",
                      general0113,
                    ),line(
                      10,
                      "EUS - 0114",
                      general0114,
                    ),line(
                      11,
                      "TER-ATA - 0115",
                      general0115,
                    ),line(
                      12,
                      "TER-VAR - 0116",
                      general0116,
                    ),
                    line(
                      13,
                      "JUA-ATA - 0102",
                      general0102,
                    ),line(
                      14,
                      "NAT-ATA - 0111",
                      general0102,
                    ),
                    lineTotal(
                      15,
                      "TOTAL",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

valueBranch(index) {
  return Text(
    "${general0112[index] +general0116[index] +general0115[index] +general0114[index] +general0102[index] +general0101[index] + general0103[index] + general0104[index] + general0105[index] + general0106[index] + general0107[index] + general0108[index] + general0109[index] + general0110[index] + general0113[index]}",
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.white, fontSize: 17),
  );
}

branchCrj(index) {
  return "${branch[index].code} ${branch[index].initials == "S/CLASS" ? "" : "- ${branch[index].initials}"} - ${branch[index].cidadeEmpresa}";
}

iconStatus(onTap, color, icon) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
      child: Icon(
        icon,
        color: color,
      ),
    ),
  );
}
