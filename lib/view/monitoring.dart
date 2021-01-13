import 'dart:async';

import 'package:clippy/browser.dart' as clippy;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monitor_geral/controller/monitor_filter_get.dart';
import 'package:monitor_geral/controller/monitor_get.dart';
import 'package:monitor_geral/global.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var pl = FocusNode();
  final _streamController = StreamController<List<Monitor>>.broadcast();
  final _streamControllerGeneral = StreamController<List<Monitor>>.broadcast();
  Timer timer;
  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 300;
  int currentSeconds = 0;
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:'
      ' ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int milliseconds]) {
    var duration = interval;

    Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (timer.tick >= timerMaxSeconds) {
            timer.cancel();
            colorApp == Colors.indigo ? _loadData() : _loadDataFilter();

            startTimeout();
          }
        });
      }
    });
  }

  @override
  void initState() {
    startTimeout();
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
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
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
                              builder: (BuildContext context) => Monitoring()));
                    });
                  },
                  items: <String>[
                    '0101',
                    '0103',
                    '0104',
                    '0105',
                    '0106',
                    '0107',
                    '0108',
                    '0109',
                    '0110',
                    '0113'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
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
                            unselectedWidgetColor: Colors.white),
                        child: TextFormField(
                          controller: _searchGfe,
                          maxLength: 8,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.white),
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
                padding: const EdgeInsets.only(left: 10, bottom: 5.0),
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
                            unselectedWidgetColor: Colors.white),
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
                            this.setState(() {
                              _searchPlate.clear();

                              plate = "";
                            });

                            _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(1999),
                      maxTime: DateTime(2050), onChanged: (datede) {
                    dataInit = datede;
                    dataInitForm = DateFormat('yyyyMMdd').format(dataInit);
                  }, onConfirm: (datede) {
                    setState(() {
                      _loadData();
                      dataInit = datede;

                      dataInitForm = DateFormat('yyyyMMdd').format(dataInit);
                    });
                  }, currentTime: dataInit, locale: LocaleType.pt);
                },
                child: Stack(children: <Widget>[
                  dataInit == null
                      ? Row(
                          children: [
                            // Icon(Icons.calendar_today,color: Colors.white,),
                            Text(
                                'De: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                )),
                          ],
                        )
                      : Row(
                          children: [
                            // Icon(Icons.calendar_today,color: Colors.white,),
                            Text(
                                'De: ${DateFormat('dd/MM/yyyy').format(dataInit)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                )),
                          ],
                        )
                ]),
              ),
              FlatButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(1999),
                      maxTime: DateTime(2050), onChanged: (dateate) {
                    dateEnd = dateate;
                    dateEndForm = DateFormat('yyyyMMdd').format(dateEnd);
                  }, onConfirm: (dateate) {
                    setState(() {
                      _loadData();
                      dateEnd = dateate;
                      dateEndForm = DateFormat('yyyyMMdd').format(dateEnd);
                    });
                  }, currentTime: dateEnd, locale: LocaleType.pt);
                },
                child: Stack(children: <Widget>[
                  dateEnd == null
                      ? Row(
                          children: [
                            //  Icon(Icons.calendar_today,color: Colors.white,),
                            Text(
                                "Até: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                )),
                          ],
                        )
                      : Row(
                          children: [
                            //  Icon(Icons.calendar_today,color: Colors.white,),
                            Text(
                                "Até: ${DateFormat('dd/MM/yyyy').format(dateEnd)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                )),
                          ],
                        )
                ]),
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Monitoring()));
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/P8.png',
                    width: MediaQuery.of(context).size.width * 0.1,
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
                stream: _streamController.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8, left: 8),
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: auditorP8
                                        ? Colors.green[900]
                                        : Colors.red[900],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: auditorP8
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.015,
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blueGrey[900],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.blueGrey[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.015,
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 8,
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan[900],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.cyan[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.015,
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, top: 8.0, bottom: 8, right: 8),
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.teal[900],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.teal[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.015,
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blueGrey,
                                      width: 1.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    color: Colors.indigo[800],
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.018,
                                                      color: Colors.white),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.03,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.015,
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
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              color: Colors.white,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.001,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Total",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.022,
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
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
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8, left: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
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
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: auditorP8
                                        ? Colors.green[900]
                                        : Colors.red[800],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: auditorP8
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                      MdiIcons
                                                          .truckCheckOutline,
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "$p8",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: auditorP8
                                                    ? Text(
                                                        "Auditados P8",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.022,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : Text(
                                                        "Pendentes de Auditoria P8",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.022,
                                                            color:
                                                                Colors.white),
                                                      )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              /*setState(() {
                                if (emtranspad != Colors.blueGrey) {
                                  emtranspad = Colors.blueGrey;
                                }
                                recebido = "";
                                conferido = "S";
                                enderecado = "";
                                portaria = "";
                                _loadDataFiltro();
                              });*/
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blueGrey[900],
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.blueGrey[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "...",
                                                    //"$conferencia",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Pendente conferência",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8, right: 8),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.cyan[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "$pending",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Entrada NF Realizada",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8, right: 8),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.teal[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    // "$ender",
                                                    "...",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Pendente endereçamento",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8.0),
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      width: MediaQuery.of(context).size.width *
                                          0.015,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    );
                                  });
                              await _loadDataGeneral();

                              Navigator.of(context).pop();

                              showDialog<void>(
                                context: context,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigator.of(context).pop();
                                    },
                                    child: StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          backgroundColor: Colors.white,
                                          title: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                dateEndForm =
                                                                    "${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                                                dataInitForm =
                                                                    "${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                                                dateEndFormGeneral =
                                                                    "${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                                                dataInitFormGeneral =
                                                                    "${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons
                                                                      .clear),
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    "Fechar",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),

                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  //Text(timerText),
                                                                ],
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          FlatButton(
                                                            onPressed: () {
                                                              DatePicker.showDatePicker(
                                                                  context,
                                                                  showTitleActions:
                                                                      true,
                                                                  minTime:
                                                                      DateTime(
                                                                          1999),
                                                                  maxTime:
                                                                      DateTime(
                                                                          2050),
                                                                  onChanged:
                                                                      (datedegeral) {
                                                                datedegeral =
                                                                    datedegeral;
                                                                dataInitFormGeneral =
                                                                    DateFormat(
                                                                            'yyyyMMdd')
                                                                        .format(
                                                                            dateInitGeneral);
                                                              }, onConfirm:
                                                                      (datedegeral) {
                                                                setState(() {
                                                                  dateInitGeneral =
                                                                      datedegeral;

                                                                  dataInitFormGeneral =
                                                                      DateFormat(
                                                                              'yyyyMMdd')
                                                                          .format(
                                                                              dateInitGeneral);
                                                                  _loadDataGeneral();
                                                                });
                                                              },
                                                                  currentTime:
                                                                      dateInitGeneral,
                                                                  locale:
                                                                      LocaleType
                                                                          .pt);
                                                            },
                                                            child: date(
                                                                dateInitGeneral,
                                                                "De"),
                                                          ),
                                                          FlatButton(
                                                            onPressed: () {
                                                              DatePicker.showDatePicker(
                                                                  context,
                                                                  showTitleActions:
                                                                      true,
                                                                  minTime:
                                                                      DateTime(
                                                                          1999),
                                                                  maxTime:
                                                                      DateTime(
                                                                          2050),
                                                                  onChanged:
                                                                      (dateategeral) {
                                                                dateEndGeneral =
                                                                    dateategeral;
                                                                dateEndFormGeneral =
                                                                    DateFormat(
                                                                            'yyyyMMdd')
                                                                        .format(
                                                                            dateategeral);
                                                              }, onConfirm:
                                                                      (dateategeral) {
                                                                setState(() {
                                                                  dateEndGeneral =
                                                                      dateategeral;
                                                                  dateEndFormGeneral =
                                                                      DateFormat(
                                                                              'yyyyMMdd')
                                                                          .format(
                                                                              dateEndGeneral);
                                                                  _loadDataGeneral();
                                                                });
                                                              },
                                                                  currentTime:
                                                                      dateEndGeneral,
                                                                  locale:
                                                                      LocaleType
                                                                          .pt);
                                                            },
                                                            child: date(
                                                                dateEndGeneral,
                                                                "Até"),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await _loadDataGeneral();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),

                                                                  Icon(Icons
                                                                      .refresh),
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    "Atualizar",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),

                                                                  //Text(timerText),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.indigo,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(5.0),
                                                          topRight: const Radius
                                                              .circular(5.0)),
                                                      color: Colors.indigo[400],
                                                    ),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 50,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                            color: colorApp,
                                                            child: Center(
                                                              child: Text(
                                                                "FILIAL",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          color: colorApp,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "Auditoria P8",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          color: colorApp,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "CONFERÊNCIA",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          color: colorApp,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "ENTRADA NF",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          color: colorApp,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "ENDEREÇAMENTO",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          color: colorApp,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                            color:
                                                                colorApp[800],
                                                            child: Center(
                                                              child: Text(
                                                                "TOTAL",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                line(0, "MCZ - 0101",
                                                    general0101),
                                                line(1, "ARA - 0103",
                                                    general0103),
                                                line(2, "JPA - 0104",
                                                    general0104),
                                                line(3, "CD - 0105",
                                                    general0105),
                                                line(4, "CGD - 0106",
                                                    general0106),
                                                line(5, "NAT - 0107",
                                                    general0107),
                                                line(6, "CBD - 0108",
                                                    general0108),
                                                line(7, "FOR - 0109",
                                                    general0109),
                                                line(8, "JUA - 0110",
                                                    general0110),
                                                line(9, "DVM - 0113",
                                                    general0113),
                                                lineTotal(10, "TOTAL"),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blueGrey,
                                    width: 1.0,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.indigo[800],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.018,
                                                    color: Colors.white),
                                              ),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "$total",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.025,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.001,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Total",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022,
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: colorApp == Colors.green
                            ? const EdgeInsets.only(left: 8, right: 8)
                            : const EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorApp[900],
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(5.0),
                                topRight: const Radius.circular(5.0)),
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                                        ? MediaQuery.of(context).size.height *
                                            0.018
                                        : MediaQuery.of(context).size.height *
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
                              ? const EdgeInsets.only(
                                  bottom: 8.0, left: 8, right: 8)
                              : const EdgeInsets.only(
                                  bottom: 8.0, left: 8, right: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorApp,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: const Radius.circular(5.0),
                                  bottomRight: const Radius.circular(5.0)),
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
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                          ),
                                          Text(
                                            "Não ha registros",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.015,
                                                color: colorApp),
                                          ),
                                        ],
                                      ));
                                    }
                                    return Scrollbar(
                                        child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: monitor.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Monitor m = monitor[index];
                                              key.add(m.keyNfe);

                                              return Column(
                                                children: [
                                                  lineMonitor(
                                                    key.length,
                                                    m.branchOrigin,
                                                    m.branchDestiny,
                                                    m.nf,
                                                    m.nfSerie,
                                                    m.observation,
                                                    m.dateEmission,
                                                    m.dateEntry,
                                                    m.dateEmission,
                                                    m.daysInTransit,
                                                    GestureDetector(
                                                      onTap: () {
                                                        register(m);
                                                      },
                                                      child: Container(
                                                        child: m.concierge ==
                                                                "N"
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        3,
                                                                        0,
                                                                        3,
                                                                        0),
                                                                child: Icon(
                                                                  MdiIcons
                                                                      .truckFastOutline,
                                                                  color: Colors
                                                                      .red[800],
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap:
                                                                    alertDetailsStatus(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          3,
                                                                          0,
                                                                          3,
                                                                          0),
                                                                  child: Icon(
                                                                    MdiIcons
                                                                        .truckCheckOutline,
                                                                    color: Colors
                                                                            .green[
                                                                        800],
                                                                  ),
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                    m.checked == "S"
                                                        ? GestureDetector(
                                                            onTap:
                                                                alertDetailsStatus(),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      3,
                                                                      0,
                                                                      3,
                                                                      0),
                                                              child: Icon(
                                                                MdiIcons
                                                                    .textBoxCheckOutline,
                                                                color: Colors
                                                                        .blueGrey[
                                                                    800],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    m.received == "S"
                                                        ? GestureDetector(
                                                            onTap:
                                                                alertDetailsStatus(),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      3,
                                                                      0,
                                                                      3,
                                                                      0),
                                                              child: Icon(
                                                                MdiIcons.import,
                                                                color: Colors
                                                                    .cyan[800],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    m.addressed == "S"
                                                        ? Container()
                                                        : Container(),
                                                  ),
                                                  lineSeparation(),
                                                ],
                                              );
                                            }));
                                  }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///atualiza monitor p8
  _loadData() async {
    _streamController.add(null);

    List<Monitor> monitor = await MonitorGet.getMonitor(
      branchCrjDestiny: dropdownValue,
      dateInit: "$dataInitForm",
      dateEnd: "$dateEndForm",
      plate: plate.toUpperCase(),
      gfe: gfe,
    );

    totalCollections = monitor.length;
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
    general0113 = [0, 0, 0, 0, 0];
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

    monitorGeneral = await MonitorGet.getMonitor(
      branchCrjDestiny: "",
      dateInit: "$dataInitFormGeneral",
      dateEnd: "$dateEndFormGeneral",
    );
    //totalcol = monitorGeral.length;
    for (int i = 0; i < monitorGeneral.length; i++) {
      totalGeneral++;
      if (monitorGeneral[i].branchDestiny == "0101") {
        if (monitorGeneral[i].concierge == "S") {
          general0101[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0101[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0101[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0101[3]++;
        }
        general0101[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0103") {
        if (monitorGeneral[i].concierge == "S") {
          general0103[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0103[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0103[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0103[3]++;
        }
        general0103[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0104") {
        if (monitorGeneral[i].concierge == "S") {
          general0104[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0104[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0104[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0104[3]++;
        }
        general0104[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0105") {
        if (monitorGeneral[i].concierge == "S") {
          general0105[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0105[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0105[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0105[3]++;
        }
        general0105[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0106") {
        if (monitorGeneral[i].concierge == "S") {
          general0106[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0106[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0106[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0106[3]++;
        }
        general0106[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0107") {
        if (monitorGeneral[i].concierge == "S") {
          general0107[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0107[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0107[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0107[3]++;
        }
        general0107[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0108") {
        if (monitorGeneral[i].concierge == "S") {
          general0108[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0108[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0108[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0108[3]++;
        }
        general0108[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0109") {
        if (monitorGeneral[i].concierge == "S") {
          general0109[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0109[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0109[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0109[3]++;
        }
        general0109[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0110") {
        if (monitorGeneral[i].concierge == "S") {
          general0110[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0110[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0110[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0110[3]++;
        }
        general0110[4]++;
      } else if (monitorGeneral[i].branchDestiny == "0113") {
        if (monitorGeneral[i].concierge == "S") {
          general0113[0]++;
        }
        if (monitorGeneral[i].received == "S") {
          general0113[1]++;
        }
        if (monitorGeneral[i].checked == "S") {
          //geral0113[2]++;
        }
        if (monitorGeneral[i].addressed == "S") {
          //geral0113[3]++;
        }
        general0113[4]++;
      }
    }

    Navigator.of(context).pop();
    _streamControllerGeneral.add(monitorGeneral);
  }

  ///filtra monitor p8
  _loadDataFilter() async {
    _streamController.add(null);

    List<Monitor> monitor2 = await MonitorFilterGet.getMonitorFilter(
      received: "$received",
      checked: "$checked",
      addressed: "$addressed",
      concierge: "$concierge",
      dateInit: "$dataInitForm",
      dateEnd: "$dateEndForm",
      plate: plate.toUpperCase(),
      gfe: gfe,
    );

    _streamController.add(monitor2);
  }

  ///alerta de detalhes
  alertDetailsStatus() {}

  line(index, text, geral) {
    return StreamBuilder(
        stream: _streamControllerGeneral.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
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
                                  color: colorApp),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                  color: Colors.white),
                              child: Text(
                                "${geral[0]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
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
                                  color: Colors.white),
                              child: Text(
                                "${geral[2]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
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
                                  color: Colors.white),
                              child: Text(
                                '${geral[1]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
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
                                  color: Colors.white),
                              child: Text(
                                "${geral[3]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
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
                                "${geral[4]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
        });
  }

  lineTotal(index, text) {
    return StreamBuilder(
        stream: _streamControllerGeneral.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
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
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: const Radius.circular(5.0),
                                  ),
                                  color: colorApp[800]),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                "${general0101[0] + general0103[0] + general0104[0] + general0105[0] + general0106[0] + general0107[0] + general0108[0] + general0109[0] + general0110[0] + general0113[0]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                "${general0101[2] + general0103[2] + general0104[2]
                                    + general0105[2] + general0106[2] + general0107[2]
                                    + general0108[2] + general0109[2] + general0110[2]
                                    + general0113[2]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                "${general0101[1] + general0103[1] + general0104[1]
                                    + general0105[1] + general0106[1] + general0107[1]
                                    + general0108[1] + general0109[1] + general0110[1]
                                    + general0113[1]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                "${general0101[3] + general0103[3] + general0104[3]
                                    + general0105[3] + general0106[3] + general0107[3]
                                    + general0108[3] + general0109[3] + general0110[3]
                                    + general0113[3]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                  borderRadius: BorderRadius.only(
                                    bottomRight: const Radius.circular(5.0),
                                  ),
                                  color: colorApp[800]),
                              child: Text(
                                "$totalGeneral",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
        });
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
      String serie,
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
      padding: const EdgeInsets.only(top: 16.0, bottom: 16),
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
              serie,
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
              )),
        ],
      ),
    );
  }

  lineMonitorCheck(
      int count,
      String origin,
      String destiny,
      String nf,
      String serie,
      String input,
      String emission,
      String day,
      dynamic inTransit,
      dynamic checkP8,
      dynamic addressed,
      dynamic checked) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16),
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
              serie,
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
              )),
        ],
      ),
    );
  }

  launchURL(String key) async {
    var url =
        'http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConteudo=XbSeqxE8pl8=&tipoConsulta=completa&nfe=$key&';
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
                borderRadius: BorderRadius.circular(20.0)),
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
                                      padding: const EdgeInsets.all(8.0),
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
                                      padding: const EdgeInsets.all(8.0),
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
                                    color: m.concierge == "N"
                                        ? Colors.grey
                                        : Colors.green,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                padding: const EdgeInsets.all(8.0),
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
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                padding: const EdgeInsets.all(8.0),
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
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                padding: const EdgeInsets.all(8.0),
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
                                    color: m.addressed == "S"
                                        ? Colors.grey
                                        : Colors.green,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
    Stack(children: <Widget>[
      date == null
          ? Row(
              children: [
                // Icon(Icons.calendar_today,color: Colors.white,),
                Text(
                    '$text: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
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
            )
    ]);
  }
}
