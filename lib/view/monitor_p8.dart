import 'dart:async';

import 'package:clippy/browser.dart' as clippy;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:monitor_geral/controller/concierge.dart';
import 'package:monitor_geral/controller/monitor_p8.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:monitor_geral/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MonitorP8 extends StatefulWidget {
  @override
  _MonitorP8State createState() => _MonitorP8State();
}

final _searchGfe = TextEditingController();
final _searchPlate = TextEditingController();
final _nfCode = TextEditingController();
bool nfValidator = true;
bool plateValidator = true;

class _MonitorP8State extends State<MonitorP8> {
  final _streamController = StreamController<List<Monitor>>.broadcast();
  Timer timer;
  final interval = Duration(seconds: 1);
  var pl = FocusNode();
  var nf = FocusNode();
  final int timerMaxSeconds = 300;
  var newMessageSound = AudioPlayer();
  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:'
      ' ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int milliseconds]) {
    var duration = interval;

    timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (timer.tick >= timerMaxSeconds) {
            _loadData();
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Future<void> initState() {
    _loadData();
    newMessageSound.setUrl("assets/teste5.mp3");

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
              Padding(
                padding: EdgeInsets.only(left: 20, right: 10),
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
                    color: Colors.white,
                  ),
                  onChanged: (String newValue) async {
                    setState(() {
                      dropdownValue = newValue;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MonitorP8(),
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
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.white,
                      cursorColor: Colors.white,
                      disabledColor: Colors.white,
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: TextFormField(
                      controller: _searchGfe,
                      autofocus: true,
                      maxLength: 8,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "Romaneio",
                        isDense: true,
                        counterText: "",
                      ),
                      onChanged: (value) {
                        if (value.length == 8) {
                          gfe = "";

                          if (_searchGfe.text.length == 8) {
                            setState(() {
                              plateValidator = false;
                              gfe = _searchGfe.text;
                              _loadDataNt();
                              pl.requestFocus();
                              pl.requestFocus();
                            });
                          } else {
                            plateValidator = true;
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Theme(
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
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        if (value.length == 7) {
                          plate = "";

                          setState(() {
                            if (_searchPlate.text.length == 7) {
                              plate = _searchPlate.text;
                              _loadDataNt();
                              nfValidator = false;
                              nf.requestFocus();
                            } else {
                              nfValidator = true;
                            }
                          });
                        }
                      },
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "Placa",
                        isDense: true,
                        counterText: "",
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.white,
                      cursorColor: Colors.white,
                      disabledColor: Colors.white,
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: TextFormField(
                      focusNode: nf,
                      controller: _nfCode,
                      maxLength: 44,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        if (value.length == 44) {
                          nfCode = "";

                          setState(
                            () async {
                              _loadDataNt();

                              nfCode = _nfCode.text;
                              _nfCode.text = "";
                              var post = await Concierge.postConcierge();

                              if (post[0]['success'] == true) {
                                await newMessageSound.seek(Duration.zero,
                                    index: 0);
                                await newMessageSound.pause();
                                setState(() {
                                  newMessageSound.play();
                                });
                              }
                              if (post[0]['success'] == false) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AlertDialog(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      title: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.black54,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10.0,
                                                ),
                                                color: Colors.black26,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.clear,
                                                      color: Colors.red,
                                                      size: 200,
                                                    ),
                                                    Text(
                                                      "${post[0]['message']}\n"
                                                      "${post[0]['warning'
                                                          ''] == null ? ""
                                                          "" : post[0]['warning'
                                                          '']}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.02,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                              nf.requestFocus();
                              _nfCode.clear();
                            },
                          );
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        labelText: "Chave Nfe",
                        isDense: true,
                        counterText: "",
                      ),
                    ),
                  ),
                ),
              ),
              Icon(Icons.timer),
              SizedBox(
                width: 5,
              ),

              Text(timerText),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ],
        title: Row(
          children: [
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                _searchGfe.text = "";
                _searchPlate.text = "";
                _nfCode.text = "";
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MonitorP8(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Monitor P8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      MdiIcons.truckCheckOutline,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                                  color: Colors.grey[900],
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                                color: Colors.grey[800],
                              ),
                              height: MediaQuery.of(
                                    context,
                                  ).size.height *
                                  0.17,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          MdiIcons.truckFastOutline,
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.001,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 4.0),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Pendente Auditoria P8",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
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
                                  color: Colors.green[900],
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                                color: Colors.green[800],
                              ),
                              height: MediaQuery.of(
                                    context,
                                  ).size.height *
                                  0.17,
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
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                              "Auditados hoje",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  oneDay = 0;
                  conference = 0;
                  pending = 0;
                  supply = 0;
                  total = 0;
                  p8Pending = 0;
                  p8Checked = 0;
                  List<Monitor> monitor = snapshot.data;

                  registry = monitor.length;
                  for (int t = 0; t < monitor.length; t++) {
                    if (monitor[t].checked == "N") {
                      conference++;
                    }
                    if (monitor[t].addressed == "N") {
                      pending++;
                    }
                    if (monitor[t].observation == "SEM PRE-NOTA") {
                      supply++;
                    }
                    if (monitor[t].concierge == "N") {
                      p8Pending++;
                    }
                    if (monitor[t].concierge == "S") {
                      p8Checked++;
                    }
                    if (monitor[t].daysInTransit != " DD" &&
                        monitor[t].daysInTransit != "0 DD" &&
                        monitor[t].daysInTransit != "1 DD") {
                      oneDay++;
                    }
                  }
                  total = monitor.length;
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
                                color: Colors.grey[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.grey[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.17,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        MdiIcons.truckFastOutline,
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
                                              "$p8Pending",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.03,
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
                                            "Pendente Auditoria P8",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.025,
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
                                color: Colors.green[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.green[800],
                            ),
                            height: MediaQuery.of(
                                  context,
                                ).size.height *
                                0.17,
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
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              "$p8Checked",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.03,
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
                                            "Auditados hoje",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.025,
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
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: colorApp == Colors.green
                              ? EdgeInsets.only(left: 8, right: 0)
                              : EdgeInsets.only(left: 8, right: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp != Colors.green
                                    ? colorApp[900]
                                    : Colors.grey[900],
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                              ),
                              color: colorApp != Colors.green
                                  ? colorApp[800]
                                  : Colors.grey[800],
                            ),
                            width: MediaQuery.of(
                              context,
                            ).size.width,
                            height: 50,
                            child: Row(
                              children: [
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
                                  flex: 2,
                                  child: Text(
                                    "Placa",
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
                                  flex: 1,
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
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: colorApp == Colors.green
                                ? EdgeInsets.only(
                                    bottom: 8.0,
                                    left: 8,
                                    right: 0,
                                  )
                                : EdgeInsets.only(
                                    bottom: 8.0,
                                    left: 8,
                                    right: 4,
                                  ),
                            child: Container(
                              width: MediaQuery.of(
                                context,
                              ).size.width,
                              height: 500,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorApp != Colors.green
                                      ? colorApp
                                      : Colors.grey,
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
                                          color: colorApp != Colors.green
                                              ? colorApp
                                              : Colors.grey,
                                          height: 70,
                                        ),
                                      );
                                    }
                                    List<Monitor> monitor = snapshot.data;
                                    if (monitor.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              MdiIcons.clipboardOutline,
                                              color: colorApp != Colors.green
                                                  ? colorApp
                                                  : Colors.grey,
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
                                                color: colorApp != Colors.green
                                                    ? colorApp
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return Scrollbar(
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: monitor.length,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          Monitor m = monitor[index];
                                          key.add(m.keyNfe);
                                          if (m.concierge == "N") {
                                            return Column(
                                              children: [
                                                lineMonitor(
                                                  m.automobilePlate,
                                                  m.gfe,
                                                  key.length,
                                                  m.branchOrigin,
                                                  m.branchDestiny,
                                                  m.nf,
                                                  m.series,
                                                  m.automobilePlate,
                                                  m.entryDate,
                                                  m.emissionDate,
                                                  m.daysInTransit,
                                                  m,
                                                ),
                                                colorApp != Colors.green
                                                    ? lineSep()
                                                    : lineSpend(),
                                              ],
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  colorApp == Colors.green
                      ? Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: colorApp == Colors.green
                                    ? EdgeInsets.only(left: 8, right: 8)
                                    : EdgeInsets.only(left: 4, right: 8),
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
                                          "Origem",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: colorApp == Colors.green
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
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
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
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
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
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
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
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
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.022,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Placa",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: colorApp == Colors.green
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
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
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.022,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Status",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: colorApp == Colors.green
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.022,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
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
                                          left: 4,
                                          right: 8,
                                        ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 500,
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
                                          List<Monitor> monitor = snapshot.data;
                                          if (monitor.isEmpty) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                      color: colorApp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return Scrollbar(
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: monitor.length,
                                              itemBuilder: (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                Monitor m = monitor[index];
                                                key.add(m.keyNfe);
                                                if (m.concierge == "S") {
                                                  return Column(
                                                    children: [
                                                      lineMonitorCheck(
                                                        m.automobilePlate,
                                                        m.gfe,
                                                        key.length,
                                                        m.branchOrigin,
                                                        m.branchDestiny,
                                                        m.nf,
                                                        m.series,
                                                        m.automobilePlate,
                                                        m.entryDate,
                                                        m.emissionDate,
                                                        m.daysInTransit,
                                                        m,
                                                      ),
                                                      lineSep(),
                                                    ],
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///atualiza monitor p8
  _loadData() async {
    currentSeconds = 0;

    _streamController.add(null);

    List<Monitor> monitor = await MonitorConciergeP8.getMonitorP8(
      plate: _searchPlate.text.toUpperCase(),
      gfe: _searchGfe.text,
    );

    _streamController.add(monitor);
    startTimeout();
  }

  ///filtra monitor p8
  _loadDataNt() async {
    currentSeconds = 0;

    _streamController.add(null);

    List<Monitor> monitor = await MonitorConciergeP8.getMonitorP8(
      plate: _searchPlate.text.toUpperCase(),
      gfe: _searchGfe.text,
    );

    _streamController.add(monitor);
  }

  ///alerta de detalhes
  alertDetailsStatus() {}

  line(index, text) {
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
                          "0",
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
                          "0",
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
                          "0",
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
                          "0",
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
                          "0",
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
                          "0",
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
  }

  lineTotal(index, text) {
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
              color: Colors.white),
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
                        child: Text(
                          "0",
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
                        child: Text(
                          "0",
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
                        child: Text(
                          "0",
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
                        child: Text(
                          "0",
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
                        child: Text(
                          "0",
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
                            color: colorApp[800]),
                        child: Text(
                          "0",
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
  }

  lineSep() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.001,
      width: MediaQuery.of(context).size.width,
      color: colorApp,
    );
  }

  lineSpend() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.001,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey,
    );
  }

  lineMonitor(
    var plateAction,
    var gfeAction,
    int count,
    String origin,
    String destiny,
    String nf,
    String series,
    String plate,
    String input,
    String emission,
    String day,
    m,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16),
      child: Row(
        children: [
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
                      await clippy.write("$nf $series");
                    },
                    child: Icon(
                      MdiIcons.noteMultipleOutline,
                      color: Colors.grey,
                    )),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "$nf $series",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  MdiIcons.magnify,
                  color: Colors.grey,
                ),
                Text(
                  plate,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
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
                GestureDetector(
                  onTap: () {
                    alertStatus(m);
                  },
                  child: m.concierge == "N"
                      ? iconStatus(
                          alertDetailsStatus(),
                          MdiIcons.truckFastOutline,
                          Colors.red[800],
                        )
                      : iconStatus(
                          alertDetailsStatus(),
                          MdiIcons.truckCheckOutline,
                          Colors.green[800],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  lineMonitorCheck(
    var plateAction,
    var gfeAction,
    int count,
    String origin,
    String destiny,
    String nf,
    String series,
    String plate,
    String input,
    String emission,
    String day,
    m,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16),
      child: Row(
        children: [
          /* Expanded(
            flex: 1,
            child: GestureDetector(
                onTap: () {
                  launchURL(chaves[cont]);
                },
                child: Icon(
                  MdiIcons.magnify,
                  color: emtranspad,
                )),
          ),*/
          Expanded(
            flex: 1,
            child: Text(
              origin,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
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
                  "$nf $series",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _searchGfe.text = gfeAction;
                    _searchPlate.text = plateAction;
                  },
                  child: Icon(
                    MdiIcons.magnify,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  plate,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ],
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
                GestureDetector(
                  onTap: () {
                    alertStatus(m);
                  },
                  child: m.concierge == "N"
                      ? iconStatus(
                          alertDetailsStatus(),
                          MdiIcons.truckFastOutline,
                          Colors.red[800],
                        )
                      : iconStatus(
                          alertDetailsStatus(),
                          MdiIcons.truckCheckOutline,
                          Colors.green[800],
                        ),
                ),
                m.checked == "S"
                    ? iconStatus(
                        alertDetailsStatus(),
                        MdiIcons.textBoxCheckOutline,
                        Colors.grey[800],
                      )
                    : Container(),

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

  void alertStatus(var m) {
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
                                                fontSize: 16),
                                          )
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
                                                fontSize: 16),
                                          )
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
                                        ).size.width *
                                        0.3,
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

  branchCrj(index) {
    return "${branch[index].code} - ${branch[index].initials}";
  }

  iconStatus(onTap, icon, color) {
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
}
