import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitor_geral/model/monitor.dart';
import 'package:monitor_geral/model/user.dart';

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
DateTime dataInit;
DateTime dateEnd;
DateTime dateInitGeneral;
DateTime dateEndGeneral;
String dateEndForm = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dataInitForm = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dateEndFormGeneral = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
String dataInitFormGeneral = "${DateFormat('yyyyMMdd').format(DateTime.now())}";
var received;
var checked;
var addressed;
var concierge;
User user;
var totalCollections;
List general0101 = [0, 0, 0, 0, 0];
List general0103 = [0, 0, 0, 0, 0];
List general0104 = [0, 0, 0, 0, 0];
List general0105 = [0, 0, 0, 0, 0];
List general0106 = [0, 0, 0, 0, 0];
List general0107 = [0, 0, 0, 0, 0];
List general0108 = [0, 0, 0, 0, 0];
List general0109 = [0, 0, 0, 0, 0];
List general0110 = [0, 0, 0, 0, 0];
List general0113 = [0, 0, 0, 0, 0];
List<Monitor> monitorGeral;
int totalGeneral = 0;
