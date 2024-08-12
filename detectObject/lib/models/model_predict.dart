import 'dart:convert';
// import 'dart:io' as io;
import 'dart:io';
// import 'package:download_assets/download_assets.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ModelsPredict {
  late String name;
  late int size;
  late String time;

  ModelsPredict(this.name, this.size, this.time);

  late List file;

  getMB() {
    return size * 0.000001;
  }

  factory ModelsPredict.fromJson(Map<dynamic, dynamic> json) {
    var name = json['model'].toString();
    int size = int.parse(json['size'].toString());
    var time = json['time'].toString();
    return ModelsPredict(name, size, time);
  }
}
