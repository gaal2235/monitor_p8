import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:monitor_geral/model/branch_carajas.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:monitor_geral/model/user.dart';


String gUrl = kDebugMode ? "https://carajaslabs.com.br/advpl" : "../../advpl";

List key = [];
int conference = 0;
int pending = 0;
int address = 0;
int supply = 0;
int total = 0;

int onDay = 0;
int pendingP8 = 0;
int checkedP8 = 0;
int p8 = 0;
int registry = 0;
var dropdownValue = '0101';
var colorApp = Colors.indigo;

DateTime? dateInit;
DateTime? dateEnd;
DateTime? dateInitGeneral;
DateTime? dateEndGeneral;

String dateEndForm = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dataInitForm = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dateEndFormGeneral = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dataInitFormGeneral = "${DateFormat('yyyyMMdd').format(DateTime.now())}";

var received;
var checked;
var addressed;
var concierge;
User? user;
var totalCollections;
List general0101 = [0, 0, 0, 0, 0];
List general0102 = [0, 0, 0, 0, 0];
List general0103 = [0, 0, 0, 0, 0];
List general0104 = [0, 0, 0, 0, 0];
List general0105 = [0, 0, 0, 0, 0];
List general0106 = [0, 0, 0, 0, 0];
List general0107 = [0, 0, 0, 0, 0];
List general0108 = [0, 0, 0, 0, 0];
List general0109 = [0, 0, 0, 0, 0];
List general0110 = [0, 0, 0, 0, 0];
List general0112 = [0, 0, 0, 0, 0];
List general0113 = [0, 0, 0, 0, 0];
List general0115 = [0, 0, 0, 0, 0];
List general0114 = [0, 0, 0, 0, 0];
List general0111 = [0, 0, 0, 0, 0];
List general0116 = [0, 0, 0, 0, 0];
List general0117 = [0, 0, 0, 0, 0];
List<Monitor?>? monitorGeneral;
int totalGeneral = 0;
List<BranchCarajas?>? branch;
int oneDay = 0;
int p8Pending = 0;
int p8Checked = 0;
var plate = "";
var gfe = "";
var nfCode = "";
