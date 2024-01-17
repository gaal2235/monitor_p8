import 'dart:async';

//import 'package:clippy/browser.dart' as clippy;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitor_geral/controller/concierge.dart';
import 'package:monitor_geral/controller/monitor_p8.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:monitor_geral/global.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monitor_geral/view/widgets/date.dart';
import 'package:url_launcher/url_launcher.dart';

class MonitorP8 extends StatefulWidget {
  @override
  _MonitorP8State createState() => _MonitorP8State();
}

final _searchGfe = TextEditingController();
final _searchPlate = TextEditingController();
final _nfCode = TextEditingController();
bool nfValidator = true;
bool progress = false;
bool loadAta = false;
bool plateValidator = true;
List<Monitor?> monitor = [];
bool fst = true;
int audited = 0;
class _MonitorP8State extends State<MonitorP8> {
  final _streamController = StreamController<List<Monitor?>?>.broadcast();
  final _streamController2 = StreamController<List<Monitor>?>.broadcast();
  final _streamController3 = StreamController<List<Monitor>?>.broadcast();
  final _streamController4 = StreamController<List<Monitor>?>.broadcast();
  Timer? timer;
  final interval = Duration(seconds: 1);
  var pl = FocusNode();
  var nf = FocusNode();
  final int timerMaxSeconds = 1200;

  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:'
      ' ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int? milliseconds]) {
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
 initState() {


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
                  onChanged: (String? newValue) async {
                    setState(() {
                      dropdownValue = newValue??'';

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
                    branchCrj(13),
                    branchCrj(14),
                    branchCrj(15),
                    branchCrj(16),

                  ].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.contains("0117")?"0117 - MCZ - MACEIO - PRAIA":value),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.06,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.white,
                      cardColor: Colors.white,
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
                  width: MediaQuery.of(context).size.width * 0.053,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.white,
                      cardColor: Colors.white,
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
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.white,
                      cardColor: Colors.white,
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0,backgroundColor: Colors.transparent),

                onPressed: () async {
                  if(dateInit==null){dateInit= DateTime.parse(DateFormat('yyyyMMdd').format(
                    DateTime.now().subtract(Duration(days: 30)),

                  ));}
                  dateInit = await getDate(context, dateInit);
                  dataInitForm = DateFormat('yyyyMMdd').format(
                    dateInit!,
                  );

                  setState(() {
                    _loadData();
                    dataInitForm = DateFormat('yyyyMMdd').format(
                      dateInit!,
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
                            dateInit!,
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
              ElevatedButton( style: ElevatedButton.styleFrom(elevation: 0,backgroundColor: Colors.transparent),
                onPressed: () async {
                  if(dateEnd==null){dateEnd= DateTime.parse(DateFormat('yyyyMMdd').format(
                    DateTime.now(),
                  ));}
                  dateEnd = await getDate(context, dateEnd);
                  dateEndForm = DateFormat('yyyyMMdd').format(
                    dateEnd!,
                  );
                  setState(() {
                    _loadData();
                    dateEndForm = DateFormat('yyyyMMdd').format(
                      dateEnd!,
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
                            dateEnd!,
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
                  Image.asset(
                    colorApp==Colors.green?
                    'assets/P8O.png':'assets/P8.png',
                    width: MediaQuery.of(context).size.width * 0.060,

                    alignment: Alignment.center,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _streamController2.stream,
        builder: (context, snapshot) {
          return SingleChildScrollView(
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
                                      color: Colors.grey[900]??Colors.grey,
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
                                      color: Colors.green[900]??Colors.green,
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
                      List<Monitor?>? monitor = snapshot.data;

                      registry = monitor?.length??0;
                      for (int t = 0; t < (monitor?.length??0); t++) {
                        if (monitor?[t]?.checked == "N") {
                          conference++;
                        }
                        if (monitor?[t]?.addressed == "N") {
                          pending++;
                        }
                        if (monitor?[t]?.observation == "SEM PRE-NOTA") {
                          supply++;
                        }
                        if (monitor?[t]?.concierge == "N") {
                          p8Pending++;
                        }
                        if (monitor?[t]?.concierge == "S") {
                          p8Checked++;
                        }
                        if (monitor?[t]?.daysInTransit != " DD" &&
                            monitor?[t]?.daysInTransit != "0 DD" &&
                            monitor?[t]?.daysInTransit != "1 DD") {
                          oneDay++;
                        }
                      }
                      total = monitor?.length??0;
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
                                    color: Colors.grey[900]??Colors.grey,
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
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "$p8Pending",
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.03,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    !progress?
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
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
                                                        :Container()
                                                  ],
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
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
                                              if(
                                              (
                                                  user?.user=="cezarbatista"||
                                                      user?.user=="marlielsongomes"||
                                                      user?.userCode=="002291"||
                                                      user?.userCode=="000001"||
                                                      user?.user=="jeansousa"||
                                                      user?.user=="danielsampaio"||
                                                      user?.user=="gabrielsilva"
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

                                                      child: ElevatedButton(
                                                      /*  style: ButtonStyle(),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(18.0),
                                                            side: BorderSide(color: Colors.green[800],)),*/
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
                                                          for (audited = 0; audited<(monitor?.length??0);audited++) {

                                                            if(
                                                            (monitor?[audited]?.branchOrigin=="0112"&&monitor?[audited]?.branchDestiny=="0109"&&monitor?[audited]?.concierge!="S")||
                                                                (monitor?[audited]?.branchOrigin=="0115"&&monitor?[audited]?.branchDestiny=="0116"&&monitor?[audited]?.concierge!="S")||
                                                                (monitor?[audited]?.branchOrigin=="0111"&&monitor?[audited]?.branchDestiny=="0107"&&monitor?[audited]?.concierge!="S")||
                                                                (monitor?[audited]?.branchOrigin=="0102"&&monitor?[audited]?.branchDestiny=="0110"&&monitor?[audited]?.concierge!="S")
                                                            ){
                                                              f = true;
                                                              total++;
                                                              gfe = monitor?[audited]?.gfe??"";
                                                              plate = monitor?[audited]?.automobilePlate??"";
                                                              nfCode = monitor?[audited]?.keyNfe??"";
                                                              await Concierge.postConcierge(ori: monitor?[audited]?.branchOrigin??"");
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
                                                        //padding: EdgeInsets.all(10.0),
                                                        //color: Colors.white,
                                                        //textColor: Colors.green[800],
                                                        child:loadAta?Center(
                                                          child: Container(
                                                            width: 15,
                                                            height: 15,
                                                            child: CircularProgressIndicator(
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]??Colors.green),
                                                            ),
                                                          ),
                                                        ): Text("  Auditar Notas de Atacado  ",

                                                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,)),
                                                      ),
                                                    );
                                                  }
                                              ),}

                                            ],
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
                                    color: Colors.green[900]??Colors.green,
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
                                        ? colorApp[900]??Colors.green
                                        : Colors.grey[900]??Colors.green,
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

                                   /* if(dropdownValue.toString().substring(0, 4)=="0109")...{

                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "Auditar",
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
                                    ),}
                                */  ],
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
                                        List<Monitor?>? monitor = snapshot.data;
                                        if (monitor?.isEmpty??false) {
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
                                            itemCount: monitor?.length,
                                            itemBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              Monitor? m = monitor?[index];
                                              key.add(m?.keyNfe);
                                              if (m?.concierge == "N") {
                                                return Column(
                                                  children: [
                                                    lineMonitor(
                                                      m?.automobilePlate,
                                                      m?.gfe,
                                                      key.length,
                                                      m?.branchOrigin??'',
                                                      m?.branchDestiny??'',
                                                      m?.nf??'',
                                                      m?.series??'',
                                                      m?.automobilePlate??'',
                                                      m?.entryDate??'',
                                                      m?.emissionDate??'',
                                                      m?.daysInTransit??'',
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
                                          color: colorApp[900]??colorApp,
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
                                              List<Monitor?>? monitor = snapshot.data;
                                              if (monitor?.isEmpty??false) {
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
                                                  itemCount: monitor?.length,
                                                  itemBuilder: (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    Monitor? m = monitor?[index];
                                                    key.add(m?.keyNfe);
                                                    if (m?.concierge == "S") {
                                                      return Column(
                                                        children: [
                                                          lineMonitorCheck(
                                                            m?.automobilePlate,
                                                            m?.gfe,
                                                            key.length,
                                                            m?.branchOrigin??'',
                                                            m?.branchDestiny??'',
                                                            m?.nf??'',
                                                            m?.series??'',
                                                            m?.automobilePlate??'',
                                                            m?.entryDate??'',
                                                            m?.emissionDate??'',
                                                            m?.daysInTransit??'',
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
          );
        }
      ),
    );
  }

  ///atualiza monitor p8
  _loadData() async {



    dateInit= DateTime.parse(DateFormat('yyyyMMdd').format(
      DateTime.now().subtract(Duration(days: 120)),

    ));
    dataInitForm = DateFormat('yyyyMMdd').format(
      dateInit!,
    );
    _streamController.add(null);
     monitor = [];
    List<Monitor?>? monitorTemp= [];
    for (int u = 0; u<100000;u++) {
      progress = false;
       monitorTemp =await MonitorConciergeP8.getMonitorP8(
        plate: _searchPlate.text.toUpperCase(),
        gfe: _searchGfe.text,
        off: u == 0?0:u == 1?1000:monitor.length,
        limit: u == 0?1000:2000,
         dateInit: "$dataInitForm",
         dateEnd: "$dateEndForm",

      );

      monitor += monitorTemp??[];

      _streamController.add(monitor);
      if((u!=0&&(monitorTemp?.length??0)<2000)||(u==0&&(monitorTemp?.length??0)<1000)){
        progress = true;
        _streamController.add(monitor);
       /* for (int s = 0; s<monitorTemp.length;s++) {
          if(monitorTemp[s].branchOrigin=="0112"&&monitorTemp[s].branchDestiny=="0109"&&monitorTemp[s].concierge!="S"){
            gfe = monitorTemp[s].gfe;
            plate = monitorTemp[s].automobilePlate;
            nfCode = monitorTemp[s].keyNfe;
            await Concierge.postConcierge(ori: monitorTemp[s].branchOrigin);
          }
        }*/
        break;
      }

    }
    if(currentSeconds==0){
      startTimeout();
    }

  }

  ///filtra monitor p8
  _loadDataNt() async {
    currentSeconds = 0;

    _streamController.add(null);

    List<Monitor?>? monitor = await MonitorConciergeP8.getMonitorP8(
      plate: _searchPlate.text.toUpperCase(),
      gfe: _searchGfe.text,
      dateInit: "$dataInitForm",
      dateEnd: "$dateEndForm",
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

                SelectableText(
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
                  child: m?.concierge == "N"
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

         /* if(dropdownValue.toString().substring(0, 4)=="0109")...{

            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (origin=="0112"||origin=="0102"||origin=="0111")?() {

                      nfCode = "";

                      _searchPlate.text=plate;
                      _searchGfe.text=gfeAction.toString();
                      setState(
                            () async {
                          _loadDataNt();

                          nfCode = m?.keyNfe;
                          _nfCode.text = "";
                          var post = await Concierge.postConcierge();


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


                        },
                      );

                    }:(){},
                    child:  Icon(
                      MdiIcons.truckCheck,
                      color: (origin=="0112"||origin=="0102"||origin=="0111")?Colors.green[800]:Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          }
*/
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

                SelectableText(
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
                  child: m?.concierge == "N"
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
                m?.checked == "S"
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
                              child: m?.concierge == "N"
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
                                    color: m?.concierge == "N"
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
                                    color: m?.concierge == "N"
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "${m?.conciergeDate}",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m?.concierge == "N"
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "${m?.conciergeUser}",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.02,
                                      color: m?.concierge == "N"
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
    return   "${branch?[index]?.code} ${branch?[index]?.initials=="S/CLASS"?"":"- ${branch?[index]?.initials}"} - ${branch?[index]?.cidadeEmpresa}";

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
